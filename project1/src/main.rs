use project1::{configuration, startup::run};
use tokio::net::TcpListener;

#[tokio::main]
async fn main() -> Result<(), std::io::Error> {
    let configuration = configuration::get_configuration().expect("Failed to read configuration.");
    let address = format!("{}:{}", configuration.database.host, configuration.application_port);
    let listener = TcpListener::bind(address).await?.into_std()?;
    run(listener)?.await
}