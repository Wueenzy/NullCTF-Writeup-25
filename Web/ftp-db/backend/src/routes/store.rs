use crate::error::{opaque_error, OpaqueError};
use crate::ftp::get_ftp;
use crate::state::AppState;
use rocket::http::Status;
use rocket::response::status;
use rocket::serde::json::Json;
use rocket::serde::Serialize;
use rocket::State;
use serde::Deserialize;
use std::io::Cursor;
use uuid::Uuid;

#[derive(Deserialize)]
pub struct StoreRequest {
    content: String,
}

#[derive(Serialize)]
pub struct StoreResponse {
    id: String,
}

#[post("/store", data = "<body>")]
pub async fn store(state: &State<AppState>, body: Json<StoreRequest>) -> Result<Json<StoreResponse>, status::Custom<Json<OpaqueError>>> {
    let id = Uuid::new_v4().to_string();

    let mut ftp = get_ftp();
    ftp.stream.put(&id, &mut Cursor::new(&body.content)).map_err(|error| opaque_error(error, Status::InternalServerError, "Cannot upload file"))?;
    state.files.lock().unwrap().insert(id.clone(), id.clone());

    Ok(Json(StoreResponse {
        id
    }))
}