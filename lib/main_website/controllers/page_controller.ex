defmodule MainWebsite.PageController do
  use MainWebsite, :controller
  alias MainWebsite.{Candidates, ViewHelpers}

  @default_cosmic_bucket Application.get_env(:cosmic, :default_bucket)

  def index(conn, _params), do: render_page(conn, "index.html")
  def about(conn, _params), do: render_page(
    conn,
    "about.html",
    mission: Cosmic.get("mission", @default_cosmic_bucket),
    question_sets: Cosmic.get_type("question-sets", @default_cosmic_bucket),
    team_members: Cosmic.get_type("team-members", @default_cosmic_bucket)
  )
  def candidates(conn, _params), do: render_page(
    conn,
    "candidates.html",
    candidates: Candidates.all(),
    highlighted: Candidates.highlighted()
  )
  def calling(conn, _params), do: render_page(conn, "calling.html")
  def calling_script(conn, params), do: render_page(
    conn,
    "calling_script.html",
    candidate: Candidates.one(params["id"])
  )
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
