defmodule MyApp.Api do
  use Ash.Api, extensions: [AshJsonApi.Api, AshGraphql.Api, AshAdmin.Api]

  graphql do
    authorize?(false)
  end

  admin do
    show?(true)
  end

  resources do
    registry MyApp.AshRegistry
  end
end
