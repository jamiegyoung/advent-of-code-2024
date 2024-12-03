defmodule Main do
  def find_muls(string) do
    Regex.scan(
      ~r/(mul\(\d+,\d+\))/,
      string,
      capture: :all_but_first
    )
  end

  def process_muls(muls) do
    muls
    |> List.flatten()
    |> Enum.map(&Regex.scan(~r/(\d+)/, &1, capture: :all_but_first))
    |> Enum.map(&List.flatten/1)
    |> Enum.reduce(0, fn [a, b], acc -> acc + String.to_integer(a) * String.to_integer(b) end)
  end

  def process(content) do
    content
      |> find_muls()
      |> process_muls()
  end

  def run() do
    case File.read("3.input") do
      {:ok, content} ->
        Benchee.run(%{"3" => fn -> process(content) end})
        final = process(content)
        IO.puts("\n")
        IO.inspect(final)
      {:error, reason} ->
        IO.puts(reason)
    end
  end
end

Main.run()
