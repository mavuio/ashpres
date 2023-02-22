# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :my_app,
  ash_apis: [MyApp.Api],
  ecto_repos: [MyApp.Repo],
  timezone: "Europe/Vienna"

config :ash, :custom_types, my_decimal: MyApp.Types.MyDecimalAshType
config :ash, :custom_types, my_localdatetime: MyApp.Types.MyLocaldatetimeAshType
config :ash, use_all_identities_in_manage_relationship?: false

config :mime, :types, %{
  "application/vnd.api+json" => ["json"]
}

# Configures the endpoint
config :my_app, MyAppWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: MyAppWeb.ErrorHTML, json: MyAppWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: MyApp.PubSub,
  live_view: [signing_salt: "lJd0saA7"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :my_app, MyApp.Mailer, adapter: Swoosh.Adapters.Local

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :mavu_form,
  default_theme: :tw_material

config :mavu_form, :themes,
  tw_vertical: MyAppBe.TwVerticalInputTheme,
  tw_horizontal: MyAppBe.TwHorizontalInputTheme,
  tw_material: MyAppBe.TwMaterialInputTheme,
  tw_default: MyAppBe.TwVerticalInputTheme

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
