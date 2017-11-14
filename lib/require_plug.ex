defmodule CandidateWebsite.RequirePlug do
  import Plug.Conn, only: [fetch_query_params: 1]
  import ShortMaps

  @required ~w(
    name big_picture donate_url facebook twitter intro_statement
    intro_paragraph issues_header issues_paragraph paid_for
    quote primary_color highlight_color header_background_color
    general_email press_email platform_header signup_prompt
  )

  @optional ~w(
    animation_fill_level target_html hero_text_color before_for_congress
    instagram
  )

  def init(default), do: default

  def call(conn, _opts) do
    candidate = "justice-democrats"

    %{"metadata" => metadata} = Cosmic.get("homepage-en", candidate)
    %{"content" => about} = Cosmic.get("about-en", candidate)

    articles =
      Cosmic.get_type("articles", candidate)
      |> Enum.map(fn %{"metadata" => ~m(headline description thumbnail priority url)} ->
           priority = as_float(priority)
           headline = truncate(headline, 60)
           description = truncate(description, 140)
           ~m(headline description thumbnail priority url)a
         end)
      |> Enum.sort(&by_priority/2)

    issues =
      Cosmic.get_type("issues", candidate)
      |> Enum.map(fn %{"title" => title, "metadata" => ~m(header intro planks priority)} ->
           priority = as_float(priority)

           planks =
             planks |> Enum.map(fn ~m(statement description) -> ~m(statement description)a end)

           ~m(title header intro planks priority)a
         end)
      |> Enum.sort(&by_priority/2)

    event_slugs = Stash.get(:event_cache, "Calendar: #{metadata["name"]}") || []

    events =
      event_slugs
      |> Enum.map(fn slug -> Stash.get(:event_cache, slug) end)
      |> Enum.sort(&EventHelp.date_compare/2)
      |> Enum.map(&EventHelp.add_date_line/1)
      |> Enum.map(&EventHelp.add_candidate_attr/1)

    mobile = is_mobile?(conn)

    # Base, non homepage
    other_data = ~m(candidate about issues mobile articles events)a

    # Add optional attrs
    optional_data = Enum.reduce(@optional, %{}, fn key, acc ->
      Map.put(acc, String.to_atom(key), metadata[key])
    end)

    # Add required attrs
    case Enum.filter(@required, &(not field_filled(metadata, &1))) do
      [] ->
        required_data =
          Enum.reduce(@required, ~m(candidate about issues mobile articles events)a, fn key, acc ->
            Map.put(acc, String.to_atom(key), metadata[key])
          end)

        data = other_data
          |> Map.merge(optional_data)
          |> Map.merge(required_data)

        conn
        |> Plug.Conn.assign(:data, data)

      non_empty ->
        Phoenix.Controller.text(
          conn,
          "Candidate #{candidate} is missing fields [#{Enum.join(non_empty, ", ")}] in homepage-en"
        )
    end
  end

  defp field_filled(map, field), do: Map.has_key?(map, field) and map[field] != ""

  defp is_mobile?(conn) do
    case List.keyfind(conn.req_headers, "user-agent", 0, "") do
      {_head, tail} -> Browser.mobile?(tail)
      _ -> false
    end
  end

  defp as_float(unknown) do
    {float, _} =
      case is_float(unknown) or is_integer(unknown) do
        true ->
          {unknown, true}

        false ->
          case unknown do
            "." <> _rest -> Float.parse("0" <> unknown)
            _ -> Float.parse(unknown)
          end
      end

    float
  end

  defp by_priority(%{priority: a}, %{priority: b}) do
    a <= b
  end

  defp truncate(string, length) do
    case String.slice(string, 0, length) do
      ^string -> string
      sliced -> sliced <> "..."
    end
  end
end
