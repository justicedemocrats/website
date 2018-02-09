defmodule MainWebsite.PageController do
  use MainWebsite, :controller

  def index(conn, _params) do
    IO.inspect(Application.get_env(:main_website, :css_src, ""))
    assigns = Map.get(conn.assigns, :data, %{})
    render(conn, "index.html", Enum.into(assigns, []))
  end
end
