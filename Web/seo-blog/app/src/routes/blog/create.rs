use crate::error::{opaque_error, OpaqueError};
use crate::routes::auth::AuthGuard;
use crate::state::AppState;
use entity::post;
use rocket::http::Status;
use rocket::response::status;
use rocket::serde::json::{serde_json, Json};
use rocket::serde::Serialize;
use rocket::State;
use rocket_dyn_templates::{context, Template};
use sea_orm::{ActiveModelTrait, Set};
use serde::Deserialize;
use std::collections::HashMap;
use uuid::Uuid;

#[derive(Deserialize)]
pub struct CreateRequest {
    title: String,
    content: String,
    meta: Vec<HashMap<String, String>>,
}

#[derive(Serialize)]
pub struct CreateResponse {
    post: post::Model,
}

#[get("/create")]
pub async fn create_view(_identity: AuthGuard) -> Template {
    Template::render("create", context! {
        title: "Create",
    })
}

#[post("/create", format = "json", data = "<data>")]
pub async fn create(state: &State<AppState>, identity: AuthGuard, data: Json<CreateRequest>) -> Result<Json<CreateResponse>, status::Custom<Json<OpaqueError>>> {
    let Json(CreateRequest { title, content, meta, }) = data;

    let meta = serde_json::to_string(&meta).unwrap();

    let post = post::ActiveModel {
        id: Set(Uuid::new_v4()),
        title: Set(title),
        content: Set(content),
        meta: Set(meta),
        user_id: Set(identity.user.id),
        ..Default::default()
    }
        .insert(&state.db)
        .await
        .map_err(|error| opaque_error(error, Status::InternalServerError, "Could not create post"))?;

    Ok(Json(CreateResponse {
        post
    }))
}