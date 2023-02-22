defmodule MyApp.Repo.Migrations.CreateRodents do
  use Ecto.Migration

  def up do
    create table(:rodents, primary_key: false) do
      add :id, :bigserial, null: false, primary_key: true
      add :nickname, :text, null: false
      add :active, :boolean, null: false, default: false
      add :type, :text, default: "unknown"
      add :inserted_at, :utc_datetime_usec, null: false, default: fragment("now()")
      add :updated_at, :utc_datetime_usec, null: false, default: fragment("now()")
    end
  end

  def down do
    drop table(:rodents)
  end
end
