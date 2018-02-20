defmodule MainWebsite.SharedView do
  use MainWebsite, :view

  def donate_url(), do: "https://secure.actblue.com/donate/justicedemocrats"
  def store_url(), do: "https://shop.justicedemocrats.com/"
end
