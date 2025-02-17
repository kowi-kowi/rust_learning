use actix_web::dev::Server;
use actix_web::{web, App, HttpServer};
use std::net::TcpListener;
use crate::routes::subscriptions::subscribe;
use crate::routes::health_check::health_check;

pub fn run(listner: TcpListener) -> Result<Server, std::io::Error> {

    let server = HttpServer::new(|| {
        App::new().route("/health_check", web::get().to(health_check))
        .route("/subscribtions", web::post().to(subscribe))
    })
    .listen(listner)?
    .run();
    Ok(server)
}