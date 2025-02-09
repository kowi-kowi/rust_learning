#!/bin/bash
set -x
set -eo pipefail

if ! [ -x "$(command -v sqlx)" ]; then
    echo "Error: sqlx is not installed." >&2
    echo "Run 'cargo install --version=0.5.7 sqlx-cli --no-default-features --features postgres' to install it." >&2
    exit 1
fi

# Variables
DB_USER="${POSTGRESUSER:=postgres}"
DB_PASSWORD="${POSTGRESPASSWORD:=password}"
DB_PORT="${POSTGRESPORT:=5432}"
CONTAINER_NAME="postgres"

APP_USER="${APP_USER:=app}"
APP_USER_PASSWORD="${APP_USER_PASSWORD:=secret}"
APP_DB_NAME="${APP_DB_NAME:=project1}"

# Remove any existing container with the same name
if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
    docker rm -f $CONTAINER_NAME
fi

# Run the PostgreSQL container
docker run \
    --env POSTGRES_USER=$DB_USER \
    --env POSTGRES_PASSWORD=$DB_PASSWORD \
    --health-cmd="pg_isready -U $DB_USER" \
    --health-interval=1s \
    --health-timeout=5s \
    --health-retries=5 \
    --publish $DB_PORT:5432 \
    --detach \
    --name $CONTAINER_NAME \
    postgres  -N 1000


# Wait for PostgreSQL to start
echo "Waiting for PostgreSQL to start..."
until [ \
    "$(docker inspect -f "{{.State.Health.Status}}" $CONTAINER_NAME)" = "healthy" \
    ]; do
    >&2 echo "Postgres is unavailable - sleeping"
    sleep 1
done

# Initialize the database (optional)
# docker exec -it $DB_CONTAINER_NAME psql -U $DB_USER -d $DB_NAME -c "CREATE TABLE example (id SERIAL PRIMARY KEY, name VARCHAR(50));"

echo "PostgreSQL database initialized and running in Docker container '$DB_CONTAINER_NAME'."

# Create the application user
CREATE_USER_SQL="CREATE USER $APP_USER WITH PASSWORD '$APP_USER_PASSWORD';"
docker exec -it $CONTAINER_NAME psql -U $DB_USER -c "$CREATE_USER_SQL"

# Grant create db privileges to the application user
GRANT_PRIVILEGES_SQL="ALTER USER $APP_USER CREATEDB;"
docker exec -it $CONTAINER_NAME psql -U $DB_USER -c "$GRANT_PRIVILEGES_SQL"

DATABASE_URL="postgresql://$APP_USER:$APP_USER_PASSWORD@localhost:$DB_PORT/$APP_DB_NAME"
export DATABASE_URL
sqlx database create
