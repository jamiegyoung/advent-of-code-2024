defmodule Main do
  def to_int(a) do
    case a do
      v when is_list(v) -> Enum.map(v, &to_int/1)
      v -> String.to_integer(v)
    end
  end

  def transpose(x) do
    Enum.zip_with(x, &Function.identity/1)
  end

  def process(content) do
    res = content
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(&String.split(&1, "   "))
      |> to_int()
      |> transpose()

    first = List.first(res)
    last = List.last(res)

    Enum.reduce(first, 0, fn x, acc ->
      acc + x * length(Enum.filter(last, fn y -> y == x end))
    end)
  end


  def run() do
    case File.read("1.input") do
      {:ok, content} ->
        Benchee.run(%{"1-2" => fn -> process(content) end})
        final = process(content)
        IO.puts("\n")
        IO.inspect(final)
      {:error, reason} ->
        IO.puts(reason)
    end
  end
end

Main.run
