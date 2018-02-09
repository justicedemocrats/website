defmodule MainWebsite.LayoutView do
  use MainWebsite, :view

  def js_script_tag, do: Application.get_env(:main_website, :js_script_tag)
  def css_link_tag, do: Application.get_env(:main_website, :css_link_tag)
end
