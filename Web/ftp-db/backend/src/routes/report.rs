use crate::error::{opaque_error, OpaqueError};
use rocket::http::Status;
use rocket::response::status;
use rocket::serde::json::Json;
use serde::Deserialize;
use std::fmt::Display;
use std::time::Duration;
use thirtyfour::{DesiredCapabilities, WebDriver};

#[derive(Deserialize)]
pub struct ReportRequest {
    id: String,
}

#[post("/report", data = "<body>")]
pub async fn report(body: Json<ReportRequest>) -> Result<(), status::Custom<Json<OpaqueError>>> {
    println!("Request to visit {}", body.id);

    let url = format!("{}/search?id={}", std::env::var("FRONTEND_ADDR").unwrap(), body.id);
    fn default_error<Error: Display>(error: Error) -> status::Custom<Json<OpaqueError>> {
        opaque_error(error, Status::InternalServerError, "Something went wrong")
    }

    let mut caps = DesiredCapabilities::firefox();
    caps.set_headless().map_err(default_error)?;
    let driver = WebDriver::new("http://localhost:4444", caps).await.map_err(default_error)?;
    driver.goto(url).await.map_err(default_error)?;
    tokio::time::sleep(Duration::from_secs(10)).await;

    Ok(())
}