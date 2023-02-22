defmodule MyApp.AshRegistry do
  use Ash.Registry

  entries do
    entry MyApp.Rodent
    entry MyApp.Bird
    entry MyApp.Ashtags.Tag
    entry MyApp.BirdToTag
  end
end
