defmodule MavuBuckets.Repo.Migrations.CreateBuckets do
  use Ecto.Migration

  def change do
    create table(:buckets) do
      add(:bkid, :string, null: false)
      add(:state, :binary)
      timestamps()
    end

    create(unique_index(:buckets, [:bkid]))
  end
end
