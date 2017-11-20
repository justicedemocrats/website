defmodule CandidateWebsite.PageController do
  import ShortMaps
  use CandidateWebsite, :controller
  plug(CandidateWebsite.RequirePlug)

  def index(conn, _params) do
    assigns = Map.get(conn.assigns, :data)

    candidates =
      "candidates"
      |> Cosmic.get_type("brand-new-congress")
      |> Enum.map(&metadata_only/1)
      |> Enum.filter(fn cand -> is_brand(cand, "jd") end)
      |> Enum.filter(&is_launched/1)
      |> Enum.filter(&has_props/1)
      |> Enum.map(&preprocess/1)
      |> Enum.sort(&by_district/2)

    num_candidates = length(candidates)

    render(
      conn,
      "index.html",
      Enum.into(assigns, candidates: candidates, num_candidates: num_candidates)
    )
  end

  def about(conn, _params) do
    %{data: assigns} = Map.take(conn.assigns, [:data, :enabled])
    render(conn, "about.html", Enum.into(assigns, []))
  end

  def platform(conn, _params) do
    assigns = Map.get(conn.assigns, :data)
    render(conn, "platform.html", Enum.into(assigns, []))
  end

  def signup(conn, params) do
    %{name: candidate_name, donate_url: donate_url} = Map.get(conn.assigns, :data)
    ~m(email zip name) = params

    [given_name, family_name] =
      case String.split(name, " ") do
        [first_only] -> [first_only, ""]
        n_list -> [List.first(n_list), List.last(n_list)]
      end

    email_address = email
    postal_addresses = [%{postal_code: zip}]

    ref = Map.get(params, "ref", nil)

    tags = ["Action: Joined Website: #{candidate_name}"]

    tags =
      if ref do
        Enum.concat(tags, ["Action: Joined Website: #{candidate_name}: #{ref}"])
      else
        tags
      end

    person = ~m(email_address postal_addresses given_name family_name)a

    person =
      if params["phone"] != nil and params["phone"] != "" do
        Map.put(person, :phone_number, params["phone"])
      else
        person
      end

    Osdi.PersonSignup.main(%{
      person: person,
      add_tags: tags
    })

    redirect(conn, external: donate_url)
  end

  def volunteer(conn, params) do
    %{name: candidate_name, donate_url: donate_url} = Map.get(conn.assigns, :data)

    data =
      Enum.reduce(~w(call_voters join_team attend_event host_event), params, fn checkbox, acc ->
        if params[checkbox] do
          Map.put(acc, checkbox, true)
        else
          Map.put(acc, checkbox, false)
        end
      end)

    ref = Map.get(params, "ref", nil)

    ~m(email zip name call_voters join_team attend_event host_event) = data

    email_address = email
    postal_addresses = [%{postal_code: zip}]

    [given_name, family_name] =
      case String.split(name, " ") do
        [first_only] -> [first_only, ""]
        n_list -> [List.first(n_list), List.last(n_list)]
      end

    person = ~m(email_address postal_addresses given_name family_name)a

    tags =
      [
        {call_voters, "Call Voters"},
        {join_team, "Join Team"},
        {attend_event, "Attend Event"},
        {host_event, "Host Event"}
      ]
      |> Enum.filter(fn {pred, _} -> pred end)
      |> Enum.map(fn {_, str} -> "Action: Volunteer Desire: #{candidate_name}: #{str}" end)
      |> Enum.concat(["Action: Joined As Volunteer: #{candidate_name}"])

    tags =
      if ref do
        Enum.concat(tags, ["Action: Joined as Volunteer: #{candidate_name}: #{ref}"])
      else
        tags
      end

    person =
      if data["phone"] != nil and data["phone"] != "" do
        Map.put(person, :phone_number, data["phone"])
      else
        person
      end

    Osdi.PersonSignup.main(%{
      person: person,
      add_tags: tags
    })

    redirect(conn, external: donate_url)
  end

  defp is_brand(~m(brands), brand), do: Enum.member?(brands, brand)

  defp metadata_only(~m(metadata title)) do
    Map.merge(metadata, ~m(title))
  end

  defp is_launched(%{"launch_status" => "Launched"}), do: true
  defp is_launched(_else), do: false

  defp has_props(candidate) do
    missing =
      ~w(district external_website website_blurb)
      |> Enum.reject(fn prop -> Map.has_key?(candidate, prop) end)

    length(missing) == 0
  end

  defp preprocess(candidate) do
    ~m(district external_website website_blurb title small_picture) = candidate
    small_picture = ~s("#{URI.encode(small_picture["imgix_url"])}")
    ~m(district external_website website_blurb small_picture title)a
  end

  defp by_district(%{district: d1}, %{district: d2}) do
    d1 <= d2
  end
end
