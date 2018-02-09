use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :main_website, MainWebsite.Endpoint,
  http: [port: 4001],
  server: false

config :main_website,
  css_link_tag: "",
  js_script_tag: ""

# Print only warnings and errors during test
config :logger, level: :warn
