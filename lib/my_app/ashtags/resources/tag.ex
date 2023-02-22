defmodule MyApp.Ashtags.Tag do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "ashtag"
    repo(MyApp.Repo)
  end

  identities do
    identity :slug, [:slug]
  end

  actions do
    # Add a set of simple actions. You'll customize these later.
    defaults [:create, :read, :update, :destroy]

    read :find_by_keyword do
      argument :keyword, :string do
        allow_nil? false
      end

      filter expr(fragment("? ILIKE ?", slug, "%" <> ^arg(:keyword) <> "%"))
    end

    actions do
      read :mavu_list do
        pagination(offset?: true)
      end
    end

    use Accessible
  end

  code_interface do
    define_for MyApp.Api
    define :get_tags_for_keyword, action: :find_by_keyword, args: [:keyword]
  end

  # relationships do
  #   has_many :products, MyApp.Stockchanges.Product
  # end

  attributes do
    uuid_primary_key(:id)

    attribute :slug, :string do
      allow_nil? false
      constraints match: ~r/^[a-z0-9_]+$/
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end


end
