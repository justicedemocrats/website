defmodule MainWebsite.DialerApi do
  use HTTPotion.Base

  # fixme delete?
  defp process_url(url, opts) do
     "https://justicedialer.com/api#{url}"
  end

  defp process_request_headers(hdrs) do
    Enum.into(hdrs, Accept: "application/json", "Content-Type": "application/json")
  end

  defp process_request_body(body) when is_map(body) do
    case Poison.encode(body) do
      {:ok, encoded} -> encoded
      {:error, problem} -> problem
    end
  end

  defp process_request_body(body) do
    body
  end

  defp process_response_body(body) do
    body |> Poison.decode!
  end

end
