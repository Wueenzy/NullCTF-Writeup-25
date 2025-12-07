use crate::state::AppState;
use entity::user;
use lazy_static::lazy_static;
use rand::distr::Alphanumeric;
use rand::Rng;
use rocket::http::Status;
use rocket::request::{FromRequest, Outcome};
use rocket::response::Redirect;
use rocket::Request;
use rocket_jwt::jwt;
use sea_orm::EntityTrait;
use std::iter::Iterator;
use std::str::FromStr;
use uuid::Uuid;

pub mod register;
pub mod login;

lazy_static! {
    static ref SECRET_KEY: String = {
        rand::rng().sample_iter(&Alphanumeric).take(32).map(char::from).collect()
    };
}

#[jwt(SECRET_KEY, cookie = "token")]
pub struct UserClaim {
    pub id: String,
}

#[allow(dead_code)]
pub struct AuthGuard {
    pub claim: UserClaim,
    pub user: user::Model,
}

#[rocket::async_trait]
impl<'r> FromRequest<'r> for AuthGuard {
    type Error = Redirect;

    async fn from_request(request: &'r Request<'_>) -> Outcome<Self, Self::Error> {
        let default_error = || Outcome::Error((Status::Unauthorized, Redirect::to(uri!("/auth/login"))));

        let state = request.rocket().state::<AppState>().unwrap();

        let token = match request.cookies().get("token") {
            Some(cookie) => Some(cookie.value().to_string()),
            None => match request.headers().get_one("Authorization") {
                Some(header) if header.starts_with("Bearer ") => Some(header.strip_prefix("Bearer ").unwrap().to_string()),
                _ => None,
            }
        };

        let Some(token) = token else {
            return default_error();
        };

        let Ok(UserClaimJwtClaim { user: claim, .. }) = UserClaim::decode(token) else {
            return default_error();
        };

        let id = Uuid::from_str(&claim.id).unwrap();
        let user = user::Entity::find_by_id(id).one(&state.db).await.unwrap().unwrap();

        Outcome::Success(AuthGuard {
            claim,
            user,
        })
    }
}