use project1::startup::run;
use tokio::net::TcpListener;

#[tokio::main]
async fn main() -> Result<(), std::io::Error> {
    let argument = "127.0.0.1:0";
    let listener = TcpListener::bind(argument).await?;
    let std_listener = listener.into_std()?;
    run(std_listener)?.await
}