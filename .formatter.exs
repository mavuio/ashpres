[
  plugins: [Phoenix.LiveView.HTMLFormatter],
  import_deps: [:ecto, :phoenix, :ash],
  inputs: ["*.{heex,ex,exs}", "priv/*/seeds.exs", "{config,lib,test}/**/*.{heex,ex,exs}"],
  subdirectories: ["priv/*/migrations"]
]
