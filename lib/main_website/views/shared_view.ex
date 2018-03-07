defmodule MainWebsite.SharedView do
  use MainWebsite, :view

  def donate_url(), do: "https://secure.actblue.com/donate/justicedemocrats"
  def store_url(), do: "https://shop.justicedemocrats.com/"
  def host_event_url(), do: "https://jdems.us/host"

  def render_calling_header(conn) do
    render "calling_header.html", conn: conn
  end

  def render_nav_item(conn, label, action) do
    render "nav_link.html",
      conn: conn,
      label: label,   # Appears as text for the link
      action: action # Needs one of the actions in MainWebsite.Router e.g. :index
  end
end
