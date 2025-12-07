use rocket::http::Status;
use rocket::response::status;
use rocket::serde::json::Json;
use serde::Serialize;
use std::backtrace::Backtrace;
use std::fmt::Display;

#[derive(Serialize)]
pub struct OpaqueError {
    error: String,
}

pub fn opaque_error<Error: Display>(error: Error, status: Status, output: &str) -> status::Custom<Json<OpaqueError>> {
    println!("{}", error);
    println!("{}", Backtrace::force_capture());
    status::Custom(status, Json(OpaqueError {
        error: output.to_string()
    }))
}