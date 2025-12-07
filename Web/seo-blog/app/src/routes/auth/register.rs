use crate::error::{opaque_error, OpaqueError};
use crate::state::AppState;
use argon2::password_hash::rand_core::OsRng;
use argon2::password_hash::SaltString;
use argon2::{Argon2, PasswordHasher};
use entity::user;
use rocket::http::Status;
use rocket::response::status;
use rocket::serde::json::Json;
use rocket::serde::Serialize;
use rocket::State;
use rocket_dyn_templates::{context, Template};
use sea_orm::{ActiveModelTrait, Set, SqlErr};
use serde::Deserialize;
use std::default::Default;
use uuid::Uuid;

#[derive(Deserialize)]
pub struct RegisterRequest {
    username: String,
    password: String,
}

#[derive(Serialize)]
pub struct RegisterResponseUser {
    id: String,
    username: String,
}

#[derive(Serialize)]
pub struct RegisterResponse {
    user: RegisterResponseUser,
}

#[get("/register")]
pub async fn register_view() -> Template {
    Template::render("register", context! {
        title: "Register",
    })
}

#[post("/register", format = "json", data = "<data>")]
pub async fn register(state: &State<AppState>, data: Json<RegisterRequest>) -> Result<Json<RegisterResponse>, status::Custom<Json<OpaqueError>>> {
    let Json(RegisterRequest { username, password }) = data;

    let salt = SaltString::generate(&mut OsRng);
    let argon2 = Argon2::default();

    let password = argon2
        .hash_password(password.as_bytes(), &salt)
        .map_err(|error| opaque_error(error, Status::InternalServerError, "Cannot hash password"))?
        .to_string();

    let user = user::ActiveModel {
        id: Set(Uuid::new_v4()),
        username: Set(username),
        password: Set(password),
        ..Default::default()
    }
        .insert(&state.db)
        .await
        .map_err(|error| {
            if let Some(SqlErr::UniqueConstraintViolation(_)) = error.sql_err() {
                return opaque_error(error, Status::Conflict, "User already exists");
            }
            opaque_error(error, Status::InternalServerError, "Cannot create user")
        })?;

    Ok(Json(RegisterResponse {
        user: RegisterResponseUser {
            id: user.id.to_string(),
            username: user.username,
        }
    }))
}