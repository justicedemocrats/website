use Mix.Config

# Configures the endpoint
config :main_website, MainWebsite.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "bfsqn9AcIMywYeFfFrwwtpRis6Jda9AQdRrc20qyXzQlB4oBV/FA+Isy4jDAB77n",
  render_errors: [view: MainWebsite.ErrorView, accepts: ~w(html json)],
  pubsub: [name: MainWebsite.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Cosmic
config :cosmic, slugs: ["project-taquito-2", "justice-democrats", "brand-new-congress"]

# Domains
config :main_website,
  domains: %{
    "www.justicedemocrats.com" => "justice-democrats",
    "justicedemocrats.com" => "justice-democrats"
  }

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
