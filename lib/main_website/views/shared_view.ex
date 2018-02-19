defmodule MainWebsite.SharedView do
  use MainWebsite, :view

  def is_current_path(conn, action) do
    Phoenix.Controller.current_path(conn) == page_path(conn, action)
  end
end
