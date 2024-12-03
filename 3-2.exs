defmodule Main do
  def find_muls(string) do
    Regex.scan(
      ~r/(do\(\))|(don't\(\))|(mul\(\d+,\d+\))/,
      string,
      capture: :all_but_first
    )
    |> Enum.map(fn x -> Enum.filter(x, fn y -> y != "" end) end)
    |> List.flatten()
  end

  def process_muls(muls) do
    muls
    |> List.flatten()
    |> Enum.map(
      &Regex.scan(~r/(\d+)|(do\(\))|(don't\(\))/, &1, capture: :all_but_first)
    )
    |> Enum.map(&List.flatten/1)
    |> Enum.map(&Enum.filter(&1, fn x -> x != "" end))
    |> Enum.reduce(
      %{flag: true, value: 0},
      fn
      [a, b], %{value: value, flag: flag} ->
        if flag == true do
          %{
            flag: flag,
            value: value + String.to_integer(a) * String.to_integer(b)
          }
        else
          %{flag: flag, value: value}
        end
      ["do()"], acc -> %{flag: true, value: acc[:value]}
      ["don't()"], acc -> %{flag: false, value: acc[:value]}
    end
    )
    |> Map.get(:value)
  end

  def process(content) do
    content
    |> find_muls()
    |> process_muls()
  end

  def run() do
    case File.read("3.input") do
      {:ok, content} ->
        Benchee.run(%{"3-2" => fn -> process(content) end})
        final = process(content)
        IO.puts("\n")
        IO.inspect(final)
      {:error, reason} ->
        IO.puts(reason)
    end
  end
end

Main.run()
