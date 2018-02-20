defmodule MainWebsite.PageController do
  use MainWebsite, :controller

  def index(conn, _params), do: render_page(conn, "index.html")
  def about(conn, _params), do: render_page(conn, "about.html")
  def candidates(conn, _params), do: render_page(conn, "candidates.html")
  def issues(conn, _params), do: render_page(conn, "issues.html")
  def joined(conn, _params), do: render_page(conn, "joined.html")

  defp assign_template_data(conn) do
    conn
    |> assign(:title, "Justice Democrats")
    |> assign(:is_current_path, fn(conn, action) -> current_path(conn) == page_path(conn, action) end)
  end

  defp render_page(conn, filename) do
    conn
    |> assign_template_data
    |> render(filename)
  end
end
