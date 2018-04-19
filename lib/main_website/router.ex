defmodule MainWebsite.Router do
  use MainWebsite, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(Plug.Session,
      store: :cookie,
      key: "_jds",
      signing_salt: "K8ea9;17sfh"
    )
  end

  scope "/", MainWebsite do
    pipe_through(:browser)

    get("/", PageController, :index)
    get("/about", PageController, :about)
    get("/candidates", PageController, :candidates)
    get("/start", PageController, :get_started)
    get("/sign-up", PageController, :sign_up)
    post("/sign-up", PageController, :submit_sign_up)
    get("/issues", PageController, :issues)
    get("/joined", PageController, :joined)
    get("/calling", PageController, :calling)
    get("/calling/script", PageController, :calling_script)
    get("/calling/dialer", PageController, :calling_dialer)
    post("/submit-dialer", PageController, :submit_dialer)
    post("/submit-dialer-confirmation", PageController, :submit_dialer_confirmation)
  end
end
