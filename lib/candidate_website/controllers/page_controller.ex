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

    extra = if Map.has_key?(params, "phone"), do: %{phone: params["phone"]}, else: %{}
    Ak.Signup.process_signup(candidate_name, Map.merge(~m(email zip name), extra))

    redirect(conn, external: donate_url)
  end

  def volunteer(conn, params) do
    %{name: candidate_name, donate_url: donate_url} = Map.get(conn.assigns, :data)

    data =
      Enum.reduce(~w(call_voters join_team attend_event host_event), params, fn checkbox, acc ->
        if params[checkbox] do
          Map.put(acc, "action_" <> checkbox, true)
        else
          Map.put(acc, "action_" <> checkbox, false)
        end
      end)

    extra = if params["ref"], do: %{source: params["ref"]}, else: %{}

    matcher = fn ~m(title) ->
      String.contains?(title, "Volunteer") and String.contains?(title, candidate_name)
    end

    Ak.Signup.process_signup(matcher, Map.merge(data, extra))
    redirect(conn, external: "https://now.justicedemocrats.com/act")
  end

  def privacy(conn, _params) do
    assigns = Map.get(conn.assigns, :data)
    ~m(content) = Cosmic.get("privacy", "justice-democrats")
    render conn, "privacy.html", Enum.into(assigns, [content: content])
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
