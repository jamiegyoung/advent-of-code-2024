defmodule Main do
  def to_int(a) do
    case a do
      v when is_list(v) -> Enum.map(v, &to_int/1)
      v -> String.to_integer(v)
    end
  end

  def get_differences(row) do
    row
    |> Enum.with_index()
    |> Enum.map(fn {v, i} ->
      case Enum.at(row, i + 1) do
        nil -> 0
        x -> x - v
      end
    end)
    |> Enum.drop(-1)
  end

  def diffs_in_bounds(diffs) do
    Enum.any?([
      Enum.all?(diffs, fn x -> x > 0 && x < 4 end),
      Enum.all?(diffs, fn x -> x < 0 && x > -4 end),
    ])
  end

  def process(content) do
    content
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.split(&1, " "))
    |> Enum.map(&to_int/1)
    |> Enum.map(&get_differences/1)
    |> Enum.filter(&diffs_in_bounds/1)
    |> length()
  end

  def run() do
    case File.read("2.input") do
      {:ok, content} ->
        Benchee.run(%{"2" => fn -> process(content) end})
        final = process(content)
        IO.puts("\n")
        IO.inspect(final)
      {:error, reason} ->
        IO.puts(reason)
    end
  end
end

Main.run()
