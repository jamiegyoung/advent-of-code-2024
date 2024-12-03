defmodule Main do
  def to_int(a) do
    case a do
      v when is_list(v) -> Enum.map(v, &to_int/1)
      v -> String.to_integer(v)
    end
  end

  def get_differences(row) do
    %{
      :row => row,
      :diffs => row
        |> Enum.with_index()
        |> Enum.map(fn {v, i} ->
          case Enum.at(row, i + 1) do
            nil -> 0
            x -> x - v
          end
        end)
        |> Enum.drop(-1)
    }
  end

  def internal_diffs_in_bounds(%{diffs: diffs}) do
    Enum.any?([
      Enum.all?(diffs, fn x -> x > 0 && x < 4 end),
      Enum.all?(diffs, fn x -> x < 0 && x > -4 end),
    ])
  end

  def generate_new_rows_from_bad_diffs(diffs, row) do
    cell_statuses = case Enum.at(diffs, 0) do
      x when x > 0 -> Enum.map(diffs, fn x -> x > 0 && x < 4 end)
      _ -> Enum.map(diffs, fn x -> x < 0 && x > -4 end)
    end

    cell_statuses
    |> Enum.with_index()
    |> Enum.reduce([], fn {v, i}, acc ->
      case v do
        false -> [i | acc]
        true -> acc
      end
    end)
    # We know the diff is bad, we don't know which index is causing it,
    # so we need to check the index before and after the bad index
    |> Enum.reduce([], fn bad_index, acc ->
      [
        List.delete_at(row, bad_index),
        List.delete_at(row, bad_index + 1),
        List.delete_at(row, bad_index - 1) | acc
      ]
    end)
    |> Enum.map(&get_differences/1)
    |> Enum.filter(&internal_diffs_in_bounds(&1))
  end

  def diffs_in_bounds(%{row: row, diffs: diffs}) do
    filtered = case Enum.at(diffs, 0) do
      x when x > 0 -> Enum.filter(diffs, fn x -> x > 0 && x < 4 end)
      _ -> Enum.filter(diffs, fn x -> x < 0 && x > -4 end)
    end

    recheck? = length(filtered) < length(diffs)

    case recheck? do
      true ->
        new_rows = generate_new_rows_from_bad_diffs(diffs, row)
        length(new_rows) > 0
      false -> true
    end
  end

  def process(content) do
    content
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.split(&1, " "))
    |> Enum.map(&to_int/1)
    |> Enum.map(&get_differences/1)
    |> Enum.filter(&diffs_in_bounds(&1))
    |> length()
  end

  def run() do
    case File.read("2.input") do
      {:ok, content} ->
        Benchee.run(%{"2-2" => fn -> process(content) end})
        final = process(content)
        IO.puts("\n")
        IO.inspect(final)
      {:error, reason} ->
        IO.puts(reason)
    end
  end
end

Main.run()
