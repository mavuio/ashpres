defmodule MyApp.Api do
  use Ash.Api, extensions: [AshJsonApi.Api]

  resources do
    registry MyApp.AshRegistry
  end
end
