defmodule MainWebsite.Router do
  use MainWebsite, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  scope "/", MainWebsite do
    pipe_through(:browser)

    get("/", PageController, :index)
    get("/about", PageController, :about)
    get("/candidates", PageController, :candidates)
    get("/start", PageController, :get_started)
    get("/issues", PageController, :issues)
    get("/joined", PageController, :joined)
  end
end
