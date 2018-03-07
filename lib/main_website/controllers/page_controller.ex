defmodule MainWebsite.PageController do
  use MainWebsite, :controller

  def index(conn, _params), do: render_page(conn, "index.html")
  def about(conn, _params), do: render_page(conn, "about.html")
  def candidates(conn, _params), do: render_page(conn, "candidates.html")
  def calling(conn, _params), do: render_page(conn, "calling.html")
  def calling_script(conn, _params), do: render_page(conn, "calling_script.html")
  def calling_dialer(conn, _params), do: render_page(conn, "calling_dialer.html")
  def get_started(conn, params), do: render_page(conn, "get_started.html", params: params)
  def issues(conn, _params), do: render_page(conn, "issues.html")
  def joined(conn, _params), do: render_page(conn, "joined.html")

  defp assign_template_data(conn) do
    conn
    |> assign(:title, "Justice Democrats")
  end

  defp render_page(conn, filename, opts \\ []) do
    conn
    |> assign_template_data
    |> render(filename, opts)
  end
end
