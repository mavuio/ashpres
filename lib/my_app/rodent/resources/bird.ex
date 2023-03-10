defmodule MyApp.Bird do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshJsonApi.Resource, AshGraphql.Resource]

  postgres do
    table("birds")
    repo(MyApp.Repo)
  end

  identities do
    identity(:nickname, [:nickname])
  end

  attributes do
    integer_primary_key(:id)

    attribute :nickname, :string do
      allow_nil?(false)
      constraints(match: ~r/^[a-z0-9_]+$/)
      description("Nickname")
    end

    attribute :active, :boolean do
      allow_nil?(false)
      default(false)
      description("is active?")
    end

    attribute :type, :atom do
      constraints(one_of: [:dove, :sparrow, :woodpecker, :cuckoo])
      default(:unknown)
      description("Type")
    end

    attribute :weight, :decimal do
      allow_nil?(true)
      description("Weight (g)")
    end

    create_timestamp(:inserted_at)
    update_timestamp(:updated_at)
  end

  actions do
    defaults([:create, :read, :update, :destroy])
  end

  actions do
    read :read_active do
      filter(expr(active == true))
    end

    read :mavu_list do
      pagination(offset?: true)
    end

    read :read_with_tags do
      prepare(build(load: [:tags]))
    end
  end

  relationships do
    many_to_many :tags, MyApp.Ashtags.Tag do
      through(MyApp.BirdToTag)
      source_attribute_on_join_resource(:bird_id)
      destination_attribute_on_join_resource(:tag_id)
    end
  end

  code_interface do
    define_for(MyApp.Api)
    define(:get_by_nickname, action: :read, get_by_identity: :nickname)
  end

  calculations do
    calculate(:full_name, :string, expr(nickname <> " " <> type(type, :string)))
  end

  json_api do
    type("bird")

    routes do
      base("/birds")

      get(:read_with_tags)
      index(:read_with_tags)
      post(:create)
      # ...
    end
  end

  graphql do
    type :bird

    queries do
      # Examples

      # create a field called `get_bird` that uses the `read` read action to fetch a single bird
      get(:get_bird, :read)

      # create a field called `list_birds` that uses the `read` read action to fetch a list of birds
      list(:list_birds, :read_with_tags)
    end

    mutations do
      # Examples

      create :create_bird, :create
      update :update_bird, :update
      destroy :destroy_bird, :destroy
    end
  end

  def clear_all() do
    MyApp.Repo.delete_all(__MODULE__)
  end

  use Accessible
end
