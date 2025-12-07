use crate::routes::auth::AuthGuard;
use crate::state::AppState;
use entity::post;
use rocket::State;
use rocket_dyn_templates::{context, Template};
use sea_orm::EntityTrait;
use std::collections::HashMap;
use std::str::FromStr;
use uuid::Uuid;

#[get("/<id>")]
pub async fn one_post(state: &State<AppState>, identity: AuthGuard, id: &str) -> Template {
    let template_error = |error| Template::render("error", context! {
        title: "Error",
        error: error,
    });

    let Ok(id) = Uuid::from_str(id) else {
        return template_error("Invalid ID");
    };

    let Some(post) = post::Entity::find_by_id(id).one(&state.db).await.unwrap() else {
        return template_error("Cannot find post");
    };

    let meta: Vec<HashMap<String, String>> = serde_json::from_str(&post.meta).unwrap();

    Template::render("post", context! {
        title: post.title.clone(),
        meta: meta,
        post: post,
        is_admin: identity.user.is_admin,
    })
}