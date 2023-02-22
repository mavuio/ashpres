defmodule MyApp.Rodent do
  use Ash.Resource, data_layer: AshPostgres.DataLayer

  postgres do
    table "rodents"
    repo(MyApp.Repo)
  end

  identities do
    identity :nickname, [:nickname]
  end

  attributes do
    integer_primary_key :id

    attribute :nickname, :string do
      allow_nil? false
      constraints match: ~r/^[a-z0-9_]+$/
      description "Nickname"
    end

    attribute :active, :boolean do
      allow_nil? false
      default false
      description "is active?"
    end

    attribute :type, :atom do
      constraints one_of: [:squirrel, :beaver, :mouse]
      default :unknown
      description "Type"
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:create, :read, :update, :destroy]
  end

  actions do
    read :read_active do
      filter expr(active == true)
    end

    read :mavu_list do
      pagination offset?: true
    end
  end

  code_interface do
    define_for MyApp.Api
    define :get_by_nickname, action: :read, get_by_identity: :nickname
  end

  def clear_all() do
    MyApp.Repo.delete_all(__MODULE__)
  end

  use Accessible
end
