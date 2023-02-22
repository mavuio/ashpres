defmodule MyApp.Rodent do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "rodents"
    repo(MyApp.Repo)
  end

  actions do
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    integer_primary_key :id

    attribute :nickname, :string do
      allow_nil? false
      constraints match: ~r/^[a-z0-9_]+$/
    end

    attribute :active, :boolean do
      allow_nil? false
      default false
    end

    attribute :type, :atom do
      constraints one_of: [:squirrel, :beaver, :mouse]
      default :unknown
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    read :mavu_list do
      pagination offset?: true
    end
  end
end
