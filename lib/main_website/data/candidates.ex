defmodule MainWebsite.Candidates do

  def all do
    "lib/main_website/data/candidates.json"
      |> File.read!()
      |> Poison.decode!()
  end

end
