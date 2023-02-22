defmodule MyApp.Repo.Migrations.CreateSnippets do
  use Ecto.Migration

  def change do
    create table(:snippets) do
      add :name, :string
      add :path, :string
      add :content, :jsonb, default: "[]"
      # add :content, :json, default: "[]"
      timestamps()
    end

    create(unique_index(:snippets, [:path]))

  end
end
