defmodule MyApp.Repo.Migrations.RodentsAddWeight do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:rodents) do
      add :weight, :decimal
    end



    create unique_index(:birds, [:nickname], name: "birds_nickname_index")
  end

  def down do


    alter table(:rodents) do
      remove :weight
    end
  end
end
