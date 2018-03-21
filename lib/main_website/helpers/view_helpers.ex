defmodule MainWebsite.ViewHelpers do
  @moduledoc """
  Conveniences for building views.
  """

  use Phoenix.HTML
  import MainWebsite.Router.Helpers
  import ShortMaps

  @doc """
  Is the given router action being viewed?
  """
  def is_current_path(conn, action), do: page_path(conn, action) == conn.request_path

  def static_path(), do: Application.get_env(:main_website, :static_path, "")

  def cosmic_safe_content(~m(content)), do: {:safe, content}
end
