defmodule MainWebsite.Candidates do
  import ShortMaps

  @mock_candidates "lib/main_website/data/mock_candidates.json" |> File.read!() |> Poison.decode!()
  @states "lib/main_website/data/states.json" |> File.read!() |> Poison.decode!()

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

  def highlighted do
    highlighted_candidates = Cosmic.get_type("highlighted-candidates", "project-taquito-2")

    "candidates"
      |> Cosmic.get_type("brand-new-congress")
      |> Enum.map(&title_and_image_only/1)
      |> Enum.filter(&is_highlighted(&1, highlighted_candidates))
  end

  defp by_district(%{district: d1}, %{district: d2}) do
    d1 <= d2
  end

  defp is_brand(~m(brands), brand), do: Enum.member?(brands, brand)

  defp is_launched(%{"launch_status" => "Launched"}), do: true
  defp is_launched(_else), do: false

  defp is_highlighted(candidate, highlighted_candidates) do
    Enum.find_value(highlighted_candidates, fn cand -> candidate["title"] == cand["title"] end)
  end

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
    state = state(district)
    ~m(district external_website website_blurb small_picture state title)a
  end

  defp title_and_image_only(~m(metadata title)) do
    ~m(small_picture) = metadata
    Map.merge(~m(small_picture), ~m(title))
  end

  def state(district) do
    parse_district(String.split(district, "-"))
  end

  def parse_district([state_abbrev, district]) do
    @states[state_abbrev]
  end

  def parse_district(string), do: string

end
