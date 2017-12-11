defmodule CandidateWebsite.AirtableShortlinks do
  use Agent

  @key Application.get_env(:candidate_website, :airtable_key)
  @base Application.get_env(:candidate_website, :airtable_base)
  @table Application.get_env(:candidate_website, :airtable_table_name)
  @view "Grid view"

  @interval 60_000

  @off Application.get_env(:candidate_website, :shortener_off, true)

  def start_link do
    queue_update()

    Agent.start_link(
      fn ->
        fetch_all() |> Enum.map(&regexify/1)
      end,
      name: __MODULE__
    )
  end

  def queue_update do
    spawn(fn ->
      :timer.sleep(@interval)
      update()
    end)
  end

  def update() do
    Agent.update(__MODULE__, fn _current ->
      fetch_all() |> Enum.map(&regexify/1)
    end)

    IO.puts("Fetched airtable updates at #{inspect(DateTime.utc_now())}")
    queue_update()
  end

  def get_all do
    Agent.get(__MODULE__, & &1)
  end

  defp fetch_all() do
    if @off do
      []
    else
      %{body: body} =
        HTTPotion.get(
          "https://api.airtable.com/v0/#{@base}/#{@table}",
          headers: [
            Authorization: "Bearer #{@key}"
          ],
          query: %{view: @view}
        )

      decoded = Poison.decode!(body)

      records =
        decoded["records"]
        |> Enum.filter(fn %{"fields" => fields} -> Map.has_key?(fields, "Destination") end)
        |> Enum.map(fn %{"fields" => %{"Pattern" => from, "Destination" => to}} ->
             {from, to}
           end)

      if Map.has_key?(decoded, "offset") do
        fetch_all(records, decoded["offset"])
      else
        records
      end
    end
  end

  defp fetch_all(records, offset) do
    %{body: body} =
      HTTPotion.get(
        "https://api.airtable.com/v0/#{@base}/#{@table}",
        headers: [
          Authorization: "Bearer #{@key}"
        ],
        query: [offset: offset, view: @view]
      )

    decoded = Poison.decode!(body)

    new_records =
      decoded["records"]
      |> Enum.filter(fn %{"fields" => fields} -> Map.has_key?(fields, "Destination") end)
      |> Enum.map(fn %{"fields" => %{"Pattern" => from, "Destination" => to}} ->
           {from, to}
         end)

    all_records = Enum.concat(records, new_records)

    if Map.has_key?(decoded, "offset") do
      fetch_all(all_records, decoded["offset"])
    else
      all_records
    end
  end

  defp regexify({from, to}) do
    {:ok, as_regex} = from |> String.downcase() |> Regex.compile()
    {as_regex, to}
  end
end
