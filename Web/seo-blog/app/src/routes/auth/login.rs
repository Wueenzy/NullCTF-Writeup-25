use crate::error::{opaque_error, OpaqueError};
use crate::routes::auth::UserClaim;
use crate::state::AppState;
use argon2::{Argon2, PasswordHash, PasswordVerifier};
use entity::user;
use rocket::http::{Cookie, CookieJar, Status};
use rocket::response::status;
use rocket::serde::json::Json;
use rocket::serde::Serialize;
use rocket::State;
use rocket_dyn_templates::{context, Template};
use sea_orm::{ColumnTrait, EntityTrait, QueryFilter};
use serde::Deserialize;

#[derive(Deserialize)]
pub struct LoginRequest {
    username: String,
    password: String,
}

#[derive(Serialize)]
pub struct LoginResponse {
    token: String,
}

#[get("/login")]
pub async fn login_view() -> Template {
    Template::render("login", context! {
        title: "Login",
    })
}

#[post("/login", format = "json", data = "<data>")]
pub async fn login(state: &State<AppState>, jar: &CookieJar<'_>, data: Json<LoginRequest>) -> Result<Json<LoginResponse>, status::Custom<Json<OpaqueError>>> {
    let Json(LoginRequest { username, password }) = data;
    let default_error = || opaque_error("", Status::NotFound, "Incorrect user or password");

    let user = user::Entity::find()
        .filter(user::Column::Username.eq(username))
        .one(&state.db)
        .await
        .map_err(|error| opaque_error(error, Status::InternalServerError, "Cannot query database"))?;

    let Some(user) = user else {
        return Err(default_error());
    };

    let hash = PasswordHash::new(&user.password).map_err(|_error| default_error())?;

    if Argon2::default().verify_password(password.as_bytes(), &hash).is_err() {
        return Err(default_error());
    }

    let token = UserClaim::sign(UserClaim {
        id: user.id.to_string()
    });

    jar.add(Cookie::build(("token", token.clone())).http_only(false).expires(None));

    Ok(Json(LoginResponse {
        token
    }))
}