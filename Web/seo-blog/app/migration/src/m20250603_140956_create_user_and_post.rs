use argon2::password_hash::rand_core::OsRng;
use argon2::password_hash::SaltString;
use argon2::{Argon2, PasswordHasher};
use sea_orm_migration::{prelude::*, schema::*};
use std::env;
use uuid::Uuid;

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .create_table(
                Table::create()
                    .table(User::Table)
                    .col(pk_uuid(User::Id))
                    .col(string(User::Username).unique_key())
                    .col(string(User::Password))
                    .col(boolean(User::IsAdmin).default(false))
                    .to_owned()
            ).await?;

        manager
            .create_table(
                Table::create()
                    .table(Post::Table)
                    .col(pk_uuid(Post::Id))
                    .col(string(Post::Title))
                    .col(string(Post::Content))
                    .col(string(Post::Meta))
                    .col(boolean(Post::IsApproved).default(false))
                    .col(boolean(Post::IsVerified).default(false))
                    .col(uuid(Post::UserId))
                    .foreign_key(
                        ForeignKey::create()
                            .from(Post::Table, Post::UserId)
                            .to(User::Table, User::Id)
                            .on_delete(ForeignKeyAction::Cascade),
                    )
                    .to_owned()
            ).await?;

        let user_id = Uuid::new_v4();

        let salt = SaltString::generate(&mut OsRng);
        let argon2 = Argon2::default();
        let password = env::var("ADMIN_PASSWORD").unwrap();

        let password = argon2
            .hash_password(password.as_bytes(), &salt)
            .unwrap()
            .to_string();


        manager.exec_stmt(
            Query::insert()
                .into_table(User::Table)
                .columns([User::Id, User::Username, User::Password, User::IsAdmin])
                .values_panic([
                    user_id.into(),
                    "admin".into(),
                    password.into(),
                    true.into(),
                ])
                .to_owned()
        ).await?;

        for (title, content, is_approved) in [
            ("flag", env::var("FLAG").unwrap().as_str(), false),
            ("Welcome", "Welcome to this blog! Don't forget to improve your SEO!", true),
            ("Something", "Idk just use the blog", true),
        ] {
            manager.exec_stmt(
                Query::insert()
                    .into_table(Post::Table)
                    .columns([Post::Id, Post::Title, Post::Content, Post::Meta, Post::IsApproved, Post::IsVerified, Post::UserId])
                    .values_panic([
                        Uuid::new_v4().into(),
                        title.into(),
                        content.into(),
                        "[]".into(),
                        is_approved.into(),
                        true.into(),
                        user_id.into(),
                    ])
                    .to_owned()
            ).await?;
        }

        Ok(())
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(Post::Table).to_owned())
            .await?;
        manager
            .drop_table(Table::drop().table(User::Table).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum User {
    Table,
    Id,
    Username,
    Password,
    IsAdmin,
}

#[derive(DeriveIden)]
enum Post {
    Table,
    Id,
    Title,
    Content,
    Meta,
    IsApproved,
    IsVerified,
    UserId,
}