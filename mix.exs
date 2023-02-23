defmodule MyApp.MixProject do
  use Mix.Project

  def project do
    [
      app: :my_app,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {MyApp.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bcrypt_elixir, "~> 3.0"},
      {:phoenix, "~> 1.7.0-rc.0", override: true},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.6"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.18.3"},
      {:phoenix_view, "~> 2.0"},
      {:heroicons, "~> 0.5"},
      {:floki, ">= 0.30.0", only: :test},
      {:swoosh, "~> 1.3"},
      {:phoenix_swoosh, "~> 1.0"},
      {:finch, "~> 0.13"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      {:quick_alias, github: "mavuio/quick_alias", branch: "master"},
      {:atomic_map, "~> 0.8"},
      {:mavu_utils, "~> 0.1.12"},
      {:mavu_form, "~> 0.1.5"},
      {:mavu_content, "~> 0.1.0"},
      {:mavu_be_user_ui, github: "mavuio/mavu_be_user_ui", branch: "main"},
      # {:mavu_list, "~> 0.2.8"},
      {:mavu_list, path: "/www/mavu_list", override: true},
      {:exsync, "~> 0.2", only: :dev},
      {:kino, "~> 0.8.1"},
      {:ash_postgres, "~> 1.1"},
      {:ash, "~> 2.6.5"},
      {:ash_phoenix, "~> 1.1"},
      {:happy_with, "~> 1.0"},
      {:ash_json_api, "~> 0.31.1"},
      {:ash_graphql, "~> 0.22.11"},
      {:absinthe_plug, "~> 1.5"},
      {:ash_admin, github: "ash-project/ash_admin", branch: "phoenix-1.7"}

      # {:mavu_snippets_ui, "~> 0.1.15"},
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
