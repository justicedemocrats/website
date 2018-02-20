defmodule MainWebsite.SharedView do
  use MainWebsite, :view

  def donate_url(), do: "https://secure.actblue.com/donate/justicedemocrats"
  def store_url(), do: "https://shop.justicedemocrats.com/"
  def host_event_url(), do: "https://jdems.us/host"
end
