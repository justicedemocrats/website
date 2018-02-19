defmodule MainWebsite.PageController do
  use MainWebsite, :controller

  def index(conn, _params) do
    assigns = Map.get(conn.assigns, :data, %{})
    render(conn, "index.html", Enum.into(assigns, []))
  end

  def about(conn, _params) do
    assigns = Map.get(conn.assigns, :data, %{})
    render(conn, "about.html", Enum.into(assigns, []))
  end

  def candidates(conn, _params) do
    assigns = Map.get(conn.assigns, :data, %{})
    render(conn, "candidates.html", Enum.into(assigns, []))
  end

  def issues(conn, _params) do
    assigns = Map.get(conn.assigns, :data, %{})
    render(conn, "issues.html", Enum.into(assigns, []))
  end

  def joined(conn, _params) do
    assigns = Map.get(conn.assigns, :data, %{})
    render(conn, "joined.html", Enum.into(assigns, []))
  end
end
