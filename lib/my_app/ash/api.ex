defmodule MyApp.Api do
  use Ash.Api

  resources do
    registry MyApp.AshRegistry
  end
end
