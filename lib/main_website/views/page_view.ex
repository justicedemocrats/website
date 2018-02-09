defmodule MainWebsite.PageView do
  use MainWebsite, :view

  def csrf_token() do
    Plug.CSRFProtection.get_csrf_token()
  end
end
