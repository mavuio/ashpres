defmodule MyApp.AshRegistry do
  use Ash.Registry

  entries do
    entry MyApp.Rodent
    entry MyApp.Bird
    entry MyApp.Bird
    entry MyApp.Ashtags.Tag
  end
end
