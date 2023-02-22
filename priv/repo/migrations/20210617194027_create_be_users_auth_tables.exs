defmodule MyApp.Repo.Migrations.CreateBeUsersAuthTables do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:be_users) do
      add :email, :citext, null: false
      add :hashed_password, :string, null: false
      add :confirmed_at, :naive_datetime
      add :is_active, :boolean, null: false, default: false
      timestamps()
    end

    create unique_index(:be_users, [:email])

    create table(:be_users_tokens) do
      add :be_user_id, references(:be_users, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create index(:be_users_tokens, [:be_user_id])
    create unique_index(:be_users_tokens, [:context, :token])
  end
end
