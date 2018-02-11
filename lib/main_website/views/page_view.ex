defmodule MainWebsite.PageView do
  use MainWebsite, :view

  def csrf_token(), do: Plug.CSRFProtection.get_csrf_token()
  def static_path(), do: Application.get_env(:main_website, :static_path, "")
end
