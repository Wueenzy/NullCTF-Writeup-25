use std::collections::HashMap;
use std::sync::Mutex;

pub struct AppState {
    pub files: Mutex<HashMap<String, String>>,
}