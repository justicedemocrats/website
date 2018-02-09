use Mix.Config

config :main_website, MainWebsite.Endpoint,
  http: [port: 4000],
  server: true

config :main_website,
  css_link_tag: ~s(<link rel="stylesheet" href="/css/app.css" media="screen,projection" />),
  js_script_tag: ~s(<script src="/js/app.js"></script>),
  proxy_base_url: "${PROXY_BASE_URL}",
  proxy_secret: "${PROXY_SECRET}"

config :logger, :console, format: "[$level] $message\n"

config :actionkit,
  base: "${AK_BASE}",
  username: "${AK_USERNAME}",
  password: "${AK_PASSWORD}"
