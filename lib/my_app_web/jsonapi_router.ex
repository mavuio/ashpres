defmodule MyAppWeb.JsonapiRouter do
  use AshJsonApi.Api.Router,
    # Your Ash.Api Module
    api: MyApp.Api,
    # Your Ash.Registry Module
    registry: MyApp.AshRegistry
end
