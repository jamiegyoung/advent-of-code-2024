defmodule Main do
  def to_int({a, b}) do
    {String.to_integer(a), String.to_integer(b)}
  end

  def diff({a, b}) do
    abs(a - b)
  end

  def transpose(x) do
    Enum.zip_with(x, &Function.identity/1)
  end

  def process(content) do
    content
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(&String.split(&1, "   "))
      |> transpose()
      |> Enum.map(&Enum.sort(&1))
      |> Enum.zip()
      |> Enum.map(&to_int/1)
      |> Enum.map(&diff/1)
      |> Enum.sum()
  end

  def run() do
    case File.read("1.input") do
      {:ok, content} ->
        Benchee.run(%{"1" => fn -> process(content) end})
        final = process(content)
        IO.puts("\n")
        IO.inspect(final)
      {:error, reason} ->
        IO.puts(reason)
    end
  end
end

Main.run()
