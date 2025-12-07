use crate::routes::auth::AuthGuard;
use crate::state::AppState;
use entity::post;
use rocket::State;
use rocket_dyn_templates::{context, Template};
use sea_orm::{ColumnTrait, EntityTrait, QueryFilter};

#[get("/")]
pub async fn posts(state: &State<AppState>, identity: AuthGuard) -> Template {
    let posts = post::Entity::find()
        .filter(post::Column::IsApproved.eq(true).or(post::Column::UserId.eq(identity.user.id)))
        .all(&state.db)
        .await
        .unwrap();

    Template::render("posts", context! {
        title: "Blog!",
        posts: posts,
    })
}