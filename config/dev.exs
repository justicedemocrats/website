use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :main_website, MainWebsite.Endpoint,
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
config :main_website, MainWebsite.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/main_website/controllers/.*(ex)$},
      ~r{lib/main_website/views/.*(ex)$},
      ~r{lib/main_website/templates/.*(eex)$}
    ]
  ]

config :main_website,
  css_link_tag: "",
  js_script_tag: ~s(<script src="http://localhost:8080/js/app.js"></script>),
  font_path: "../static",
  proxy_base_url: "${PROXY_BASE_URL}",
  proxy_secret: "${PROXY_SECRET}"

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

config :actionkit,
  base: "${AK_BASE}",
  username: "${AK_USERNAME}",
  password: "${AK_PASSWORD}"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20
