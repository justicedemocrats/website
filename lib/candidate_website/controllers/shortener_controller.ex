defmodule CandidateWebsite.ShortenerController do
  use CandidateWebsite, :controller

  def index(conn = %{request_path: path}, _params) do
    path = String.downcase(path)
    routes = CandidateWebsite.AirtableShortlinks.get_all()

    IO.inspect(routes)

    tuple_or_nil =
      routes
      |> Enum.filter(&matches(&1, path))
      |> List.first()

    destination =
      case tuple_or_nil do
        nil -> "https://justicedemocrats.com"
        {_, destination} -> destination
      end

    redirect(conn, external: https_prefix(destination))
  end

  defp matches({regex, destination}, path) do
    Regex.run(regex, path) != nil
  end

  defp https_prefix(url = "http" <> _rest) do
    url
  end

  defp https_prefix(url) do
    "https://" <> url
  end
end
