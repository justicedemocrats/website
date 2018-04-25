use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :candidate_website, CandidateWebsite.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/.bin/webpack-dev-server",
      "--inline",
      "--colors",
      "--hot",
      "--stdin",
      "--host",
      "localhost",
      "--port",
      "8080",
      "--public",
      "localhost:8080",
      cd: Path.expand("../assets", __DIR__)
    ]
  ]

# Watch static and templates for browser reloading.
config :candidate_website, CandidateWebsite.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/candidate_website/controllers/.*(ex)$},
      ~r{lib/candidate_website/views/.*(ex)$},
      ~r{lib/candidate_website/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

config :actionkit,
  base: System.get_env("AK_BASE"),
  username: System.get_env("AK_USERNAME"),
  password: System.get_env("AK_PASSWORD")

config :candidate_website,
  proxy_base_url: System.get_env("PROXY_BASE_URL"),
  proxy_secret: System.get_env("PROXY_SECRET")

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20
