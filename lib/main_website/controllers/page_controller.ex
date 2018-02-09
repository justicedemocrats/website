defmodule MainWebsite.PageController do
  use MainWebsite, :controller

  def index(conn, _params) do
    assigns = Map.get(conn.assigns, :data, %{})
    render(conn, "index.html", Enum.into(assigns, []))
  end
end
