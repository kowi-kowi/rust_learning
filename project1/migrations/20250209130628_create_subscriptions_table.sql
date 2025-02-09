-- Add migration script here
--create table subscriptions(
create table subscriptions(
    id uuid not null,
    PRIMARY KEY (id),
    email varchar(255) not null,
    name varchar(255) not null,
    created_at timestamp default current_timestamp
);
