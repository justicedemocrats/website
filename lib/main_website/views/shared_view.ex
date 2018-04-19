defmodule MainWebsite.SharedView do
  use MainWebsite, :view
  alias MainWebsite.{Candidates}

  def donate_url(), do: "https://secure.actblue.com/donate/justicedemocrats"
  def store_url(), do: "https://shop.justicedemocrats.com/"
  def host_event_url(), do: "https://jdems.us/host"
  def csrf_token(), do: Plug.CSRFProtection.get_csrf_token()

  def render_calling_header(conn, params) do
    render "calling_header.html", conn: conn, params: params
  end

  def render_candidate_chooser(conn) do
    render "candidate_chooser.html",
      conn: conn,
      candidates: Candidates.callable()
  end

  def render_nav_item(conn, label, action) do
    render "nav_link.html",
      conn: conn,
      label: label,   # Appears as text for the link
      action: action # Needs one of the actions in MainWebsite.Router e.g. :index
  end
end
