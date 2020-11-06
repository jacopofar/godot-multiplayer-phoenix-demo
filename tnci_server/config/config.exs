# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :tnci_server, TnciServerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Q4V2N56NjUdIUwcTp5/nolDLK1MUGI6PF4nPNApq05NQ3Ypbr615nUUyUGorw6DR",
  render_errors: [view: TnciServerWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: TnciServer.PubSub,
  live_view: [signing_salt: "73eTQV/u"]
  # to listen on IPv6
  # http: [port: 4000, transport_options: [socket_opts: [:inet6]]]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
