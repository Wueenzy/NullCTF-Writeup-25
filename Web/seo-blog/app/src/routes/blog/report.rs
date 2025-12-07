use std::env;
use std::fmt::Display;
use crate::error::{opaque_error, OpaqueError};
use crate::routes::auth::AuthGuard;
use crate::state::AppState;
use entity::post;
use rocket::http::Status;
use rocket::response::status;
use rocket::serde::json::Json;
use rocket::State;
use sea_orm::EntityTrait;
use std::str::FromStr;
use std::time::Duration;
use thirtyfour::{By, DesiredCapabilities, WebDriver};
use thirtyfour::error::WebDriverResult;
use uuid::Uuid;

#[post("/report/<id>")]
pub async fn report(state: &State<AppState>, _identity: AuthGuard, id: &str) -> Result<(), status::Custom<Json<OpaqueError>>> {
    let Ok(id) = Uuid::from_str(id) else {
        return Err(opaque_error("", Status::BadRequest, "Invalid ID"));
    };

    let Some(post) = post::Entity::find_by_id(id).one(&state.db).await.unwrap() else {
        return Err(opaque_error("", Status::NotFound, "Post not found"));
    };

    fn default_error<Error: Display>(error: Error) -> status::Custom<Json<OpaqueError>> {
        opaque_error(error, Status::InternalServerError, "Something went wrong")
    }

    async fn report(id: &str) -> WebDriverResult<()> {
        let mut caps = DesiredCapabilities::firefox();
        caps.set_headless()?;

        let driver = WebDriver::new("http://localhost:4444", caps).await?;
        driver.goto("http://localhost:8000/auth/login").await?;

        let username_input = driver.find(By::Name("username")).await?;
        username_input.send_keys("admin").await?;

        let password_input = driver.find(By::Name("password")).await?;
        password_input.send_keys(env::var("ADMIN_PASSWORD").unwrap()).await?;

        let submit_button = driver.find(By::Css("button[type='submit']")).await?;
        submit_button.click().await?;
        tokio::time::sleep(Duration::from_secs(2)).await;

        driver.goto(format!("http://localhost:8000/{}", id)).await?;
        tokio::time::sleep(Duration::from_secs(2)).await;

        Ok(())
    }

    report(&post.id.to_string()).await.map_err(default_error)?;

    Ok(())
}