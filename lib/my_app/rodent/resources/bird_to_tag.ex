defmodule MyApp.BirdToTag do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "bird_to_tag"
    repo(MyApp.Repo)

    references do
      reference(:bird, on_delete: :delete, on_update: :update)
    end
  end

  actions do
    defaults [:create, :read, :update, :destroy]
  end

  relationships do
    belongs_to :bird, MyApp.Bird,
      primary_key?: true,
      allow_nil?: false,
      attribute_type: :integer

    belongs_to :tag, MyApp.Ashtags.Tag, primary_key?: true, allow_nil?: false
  end

  use Accessible
end
