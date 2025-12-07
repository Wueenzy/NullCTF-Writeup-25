pub use sea_orm_migration::prelude::*;

mod m20250603_140956_create_user_and_post;

pub struct Migrator;

#[async_trait::async_trait]
impl MigratorTrait for Migrator {
    fn migrations() -> Vec<Box<dyn MigrationTrait>> {
        vec![
            Box::new(m20250603_140956_create_user_and_post::Migration),
        ]
    }
}
