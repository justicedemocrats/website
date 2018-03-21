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
      |> Enum.sort(&by_location/2)
  end

  def highlighted do
    highlighted_candidates = Cosmic.get_type("highlighted-candidates", "project-taquito-2")

    "candidates"
      |> Cosmic.get_type("brand-new-congress")
      |> Enum.map(&metadata_only/1)
      |> Enum.map(&preprocess/1)
      |> Enum.filter(&is_highlighted(&1, highlighted_candidates))
      |> IO.inspect
  end

  defp by_location(%{state_and_district: sd1}, %{state_and_district: sd2}) do
    sd1 <= sd2
  end

  defp district_format_long(state, {district_num, _}) do
    last_num = district_num |> Integer.digits() |> List.last()

    case last_num do
      1 -> "1st District"
      2 -> "2nd District"
      3 -> "3rd District"
      _ -> "#{district_num}th district"
    end
  end

  defp district_format_long(state, :error), do: ""

  defp is_brand(~m(brands), brand), do: Enum.member?(brands, brand)

  defp is_launched(%{"launch_status" => "Launched"}), do: true
  defp is_launched(_else), do: false

  defp is_highlighted(candidate, highlighted_candidates) do
    Enum.find_value(highlighted_candidates, fn cand -> candidate.title == cand["title"] end)
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

  defp parse_district(district) do
    district
    |> String.split("-")
    |> parse_office_parts()
  end

  ## For the US Senate
  defp parse_office_parts([state_abbrev, "SN"]) do
    state = @states[state_abbrev]

    %{
      chamber: "Senate",
      office_details: %{
        short: "SN",
        medium: "Senate",
        long: "#{state} Senate"
      },
      office_title: "Senate",
      office_title_long: "Senator of #{state}",
      state: state,
      state_abbrev: state_abbrev
    }
  end

  ## For the US House of Representatives
  defp parse_office_parts([state_abbrev, district_short]) do
    state = @states[state_abbrev]
    district_long = district_format_long(state, Integer.parse(district_short))

    %{
      chamber: "Congress",
      office_details: %{
        short: district_short,
        medium: state <> " " <> district_short,
        long: district_long
      },
      office_title: "Congress • #{district_long}",
      office_title_long: "Congressperson for the #{district_long}",
      state: state,
      state_abbrev: state_abbrev
    }
  end

  ## For Governors?
  defp parse_office_parts([title]) do
    %{chamber: nil, office_title: title, state: nil, state_abbrev: nil}
  end

  ## For unknown offices
  defp parse_office_parts(string) do
    %{chamber: nil, office_title: string, state: nil, state_abbrev: nil}
  end

  defp preprocess(candidate) do
    ~m(district external_website website_blurb title small_picture) = candidate
    small_picture = URI.encode(small_picture["imgix_url"])
    state_and_district = candidate["district_display"] || district
    ~m(chamber office_title state state_abbrev)a = parse_district(state_and_district)

    ~m(
      chamber
      external_website
      office_title
      small_picture
      state
      state_abbrev
      state_and_district
      title
      website_blurb
    )a
  end

  defp title_and_image_only(~m(metadata title)) do
    ~m(external_website small_picture) = metadata
    ~m(external_website small_picture title)
  end

end
