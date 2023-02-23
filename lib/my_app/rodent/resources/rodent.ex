defmodule MyApp.Rodent do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshJsonApi.Resource, AshGraphql.Resource]

  postgres do
    table "rodents"
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
      constraints(one_of: [:squirrel, :beaver, :mouse])
      default(:unknown)
      description("Type")
    end

    attribute :weight, :decimal do
      allow_nil?(true)
      description("Weight (kg)")
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
  end

  code_interface do
    define_for(MyApp.Api)
    define(:get_by_nickname, action: :read, get_by_identity: :nickname)
  end

  calculations do
    calculate(:full_name, :string, expr(nickname <> " " <> type(type, :string)))
  end

  def clear_all() do
    MyApp.Repo.delete_all(__MODULE__)
  end

  json_api do
    type("rodent")

    routes do
      base("/rodents")

      get(:read)
      index(:read)
      post(:create)
      # ...
    end
  end

  use Accessible
end
