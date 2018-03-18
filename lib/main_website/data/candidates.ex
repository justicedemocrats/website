defmodule MainWebsite.Candidates do
  import ShortMaps

  def all do
    "candidates"
      |> Cosmic.get_type("brand-new-congress")
      |> Enum.map(&metadata_only/1)
      |> Enum.filter(fn cand -> is_brand(cand, "jd") end)
      |> Enum.filter(&is_launched/1)
      |> Enum.filter(&has_props/1)
      |> Enum.map(&preprocess/1)
      |> Enum.sort(&by_district/2)
  end

  def mock do
    "lib/main_website/data/candidates.json"
      |> File.read!()
      |> Poison.decode!()
  end

  defp by_district(%{district: d1}, %{district: d2}) do
    d1 <= d2
  end

  defp is_brand(~m(brands), brand), do: Enum.member?(brands, brand)

  defp is_launched(%{"launch_status" => "Launched"}), do: true
  defp is_launched(_else), do: false

  defp has_props(candidate) do
    missing =
      ~w(district external_website website_blurb)
      |> Enum.reject(fn prop -> Map.has_key?(candidate, prop) end)

    length(missing) == 0
  end

  defp metadata_only(~m(metadata title)) do
    Map.merge(metadata, ~m(title))
  end

  defp preprocess(candidate) do
    ~m(district external_website website_blurb title small_picture) = candidate
    small_picture = URI.encode(small_picture["imgix_url"])
    district = candidate["district_display"] || district
    ~m(district external_website website_blurb small_picture title)a
  end

end
