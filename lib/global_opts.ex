defmodule GlobalOpts do
  @domains Application.get_env(:candidate_website, :domains)

  def get(_conn, _params) do
    [candidate: "justice-democrats"]
  end
end
