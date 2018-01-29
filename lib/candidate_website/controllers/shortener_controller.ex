defmodule CandidateWebsite.ShortenerController do
  use CandidateWebsite, :controller

  def index(conn = %{request_path: path}, _params) do
    path = String.downcase(path)
    redirect(conn, external: jdems_prefix(path))
  end

  defp jdems_prefix(path) do
    "https://jdems.us/#{path}"
  end
end
