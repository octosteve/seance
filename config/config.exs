# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :seance,
  ecto_repos: [Seance.Repo]

# Configures the endpoint
config :seance, SeanceWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "BXBKlui+dkBBp7RHaNbfqXECrlbnsU+ED/PjPEdmz67sJYFyg802lTAf5utbnYxi",
  render_errors: [view: SeanceWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Seance.PubSub,
  live_view: [signing_salt: "sb1pZOZK"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
