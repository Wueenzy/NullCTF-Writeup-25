#[macro_use]
extern crate rocket;
mod state;
mod routes;
mod error;

use crate::routes::auth::login::{login, login_view};
use crate::routes::auth::register::{register, register_view};
use crate::routes::blog::create::{create, create_view};
use crate::routes::blog::post::one_post;
use crate::routes::blog::posts::posts;
use crate::routes::blog::verify::verify;
use crate::state::AppState;
use migration::{Migrator, MigratorTrait};
use rocket::fs::{relative, FileServer};
use rocket::response::Redirect;
use rocket_dyn_templates::Template;
use sea_orm::Database;
use std::env;
use crate::routes::blog::report::report;

#[launch]
async fn rocket() -> _ {
    let db = Database::connect(env::var("DATABASE_URL").expect("DATABASE_URL")).await.expect("Database");
    Migrator::up(&db, None).await.expect("Migration");

    let state = AppState {
        db,
    };

    rocket::build()
        .register("/", catchers![unauthorized])
        .mount("/", routes![
            posts,
            one_post,
            create_view, create,
            verify,
            report,
        ])
        .mount("/auth", routes![
            register_view, register,
            login_view, login
        ])
        .mount("/static", FileServer::from(relative!("static")))
        .attach(Template::fairing())
        .manage(state)
}

#[catch(401)]
fn unauthorized() -> Redirect {
    Redirect::to(uri!("/auth/login"))
}