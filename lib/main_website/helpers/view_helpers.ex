defmodule MainWebsite.ViewHelpers do
  @moduledoc """
  Conveniences for building views.
  """

  use Phoenix.HTML
  import MainWebsite.Router.Helpers

  @doc """
  Is the given router action being viewed?
  """
  def is_current_path(conn, action), do: page_path(conn, action) == conn.request_path
end
