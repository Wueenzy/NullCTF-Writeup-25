use crate::error::{opaque_error, OpaqueError};
use crate::routes::auth::AuthGuard;
use crate::state::AppState;
use entity::post;
use rocket::http::Status;
use rocket::response::status;
use rocket::serde::json::Json;
use rocket::State;
use sea_orm::{ActiveModelTrait, EntityTrait, IntoActiveModel, Set};
use std::str::FromStr;
use uuid::Uuid;

#[post("/verify/<id>")]
pub async fn verify(state: &State<AppState>, identity: AuthGuard, id: &str) -> Result<(), status::Custom<Json<OpaqueError>>> {
    if !identity.user.is_admin {
        return Err(opaque_error("", Status::Forbidden, "Admin only"));
    }
    let Ok(id) = Uuid::from_str(id) else {
        return Err(opaque_error("", Status::BadRequest, "Invalid ID"));
    };

    let Some(post) = post::Entity::find_by_id(id).one(&state.db).await.unwrap() else {
        return Err(opaque_error("", Status::NotFound, "Post not found"));
    };
    let mut post = post.into_active_model();

    post.is_verified = Set(true);
    post.update(&state.db).await.unwrap();

    Ok(())
}