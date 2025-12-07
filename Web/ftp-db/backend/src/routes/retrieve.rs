use crate::error::{opaque_error, OpaqueError};
use crate::ftp::get_ftp;
use rocket::http::Status;
use rocket::response::status;
use rocket::serde::json::Json;
use rocket::State;
use serde::Serialize;
use crate::state::AppState;

#[derive(Serialize)]
pub struct RetrieveResponse {
    content: String,
}

#[get("/retrieve/<id>")]
pub async fn retrieve(state: &State<AppState>, id: &str) -> Result<Json<RetrieveResponse>, status::Custom<Json<OpaqueError>>> {
    let mut ftp = get_ftp();
    let files = state.files.lock().unwrap();
    let filename = files.get(id);
    let Some(filename) = filename else {
        return Err(opaque_error("", Status::BadRequest, "File not found"));
    };
    let cursor = ftp.stream.simple_retr(filename).map_err(|error| opaque_error(error, Status::BadRequest, "Could not retrieve file"))?;
    let buf = cursor.into_inner();
    let content = str::from_utf8(&buf).map_err(|error| opaque_error(error, Status::InternalServerError, "Could not parse file"))?;

    Ok(Json(RetrieveResponse {
        content: content.to_owned(),
    }))
}