defmodule CandidateWebsite.AirtableShortlinks do
  use Agent

  @key Application.get_env(:shorten, :airtable_key)
  @base Application.get_env(:shorten, :airtable_base)
  @table Application.get_env(:shorten, :airtable_table_name)

  @interval 60_000

  def start_link do
    Process.send_after(self, :update, @interval)

    Agent.start_link(
      fn ->
        fetch_all() |> Enum.map(&regexify/1)
      end,
      name: __MODULE__
    )
  end

  def update do
    receive do
      :update ->
        Agent.update(__MODULE__, fn _current ->
          fetch_all() |> Enum.map(&regexify/1)
        end)

        IO.puts("Updated at #{inspect(DateTime.utc_now(0))}")

        Process.send_after(self, :update, @interval)
        update()
    end
  end

  def get_all do
    Agent.get(__MODULE__, & &1)
  end

  defp fetch_all() do
    %{body: body} =
      HTTPotion.get("https://api.airtable.com/v0/#{@base}/#{@table}", headers: [
        Authorization: "Bearer #{@key}"
      ])

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

  defp fetch_all(records, offset) do
    %{body: body} =
      HTTPotion.get(
        "https://api.airtable.com/v0/#{@base}/#{@table}",
        headers: [
          Authorization: "Bearer #{@key}"
        ],
        query: [offset: offset]
      )

    decoded = Poison.decode!(body) |> IO.inspect()

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
