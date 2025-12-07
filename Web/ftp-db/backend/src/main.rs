#[macro_use]
extern crate rocket;
mod state;
mod routes;
mod ftp;
mod error;

use crate::ftp::get_ftp;
use crate::routes::report::report;
use crate::routes::retrieve::retrieve;
use crate::routes::store::store;
use crate::state::AppState;
use std::collections::HashMap;
use std::env;
use std::io::Cursor;
use std::sync::Mutex;
use uuid::Uuid;

fn put_flag(state: &mut AppState) {
    let flag = env::var("FLAG").unwrap();
    let id = Uuid::new_v4().to_string();

    get_ftp().stream.put("flag.txt", &mut Cursor::new(flag)).unwrap();
    state.files.lock().unwrap().insert(id, "flag.txt".to_owned());
}

#[launch]
fn rocket() -> _ {
    let mut state = AppState {
        files: Mutex::new(HashMap::new()),
    };

    put_flag(&mut state);


    rocket::build()
        .mount("/", routes![store, retrieve, report])
        .manage(state)
}
