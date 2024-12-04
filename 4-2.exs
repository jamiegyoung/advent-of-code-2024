defmodule Main do
  def char_indexes(content, char) do
    content
    |> Enum.with_index()
    |> Enum.filter(fn {c, _} -> c == char end)
    |> Enum.map(fn {_, i} -> i end)
  end

  def extract_diagonal(matrix, row, col, direction) do
    matrix
    |> Enum.with_index()
    |> Enum.reduce([], fn {r, ri}, racc ->
      racc ++ extract_row_diagonal(r, ri, row, col, direction)
    end)
  end


  defp extract_row_diagonal(row, ri, row_origin, col_origin, direction) do
    row
    |> Enum.with_index()
    |> Enum.reduce([], fn {c, ci}, cacc ->
      if (ri - row_origin) * direction == ci - col_origin do
        # Mark the origin of the match with 1
        if ri - row_origin == 0 do
          [1 | cacc]
        else
          [c | cacc]
        end
      else
        cacc
      end
    end)
  end

  def transpose(matrix) do
    Enum.zip_with(matrix, &Function.identity/1)
  end

  def charset_bidirectional_contains(char_list, charset) do
    char_list_string = Enum.join(char_list, "")
    charset_string = List.to_string(charset)
    forwards_contains = String.contains?(char_list_string, charset_string)
    backwards_contains = String.contains?(char_list_string, String.reverse(charset_string))

    Enum.any?([forwards_contains, backwards_contains], fn x -> x end)
  end

  def filter_to_matches(content, indexes, chars) do
    indexes_with_index = Enum.with_index(indexes)

    Enum.reduce(indexes_with_index, 0, fn {row_indexes, row_index}, acc ->
      Enum.reduce(row_indexes, acc, fn index, iacc ->
        pos_diag = extract_diagonal(content, row_index, index, -1)
        neg_diag = extract_diagonal(content, row_index, index, 1)
        # Check if both a positive and negative diagonal contain the charset
        # either forwards or backwards
        is_mas = charset_bidirectional_contains(pos_diag, chars) && charset_bidirectional_contains(neg_diag, chars)

        if is_mas do
          iacc + 1
        else
          iacc
        end
      end)
    end)
  end

  def process(content) do
    split_content = content
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(fn x ->
        String.split(x, "")
        |> Enum.reject(fn x -> x == "" end)
      end)

    indexes = split_content
      |> Enum.map(fn x -> char_indexes(x, "A") end)

    split_content
      |> filter_to_matches(indexes, ~c"M1S")
  end

  def run() do
    case File.read("4.input") do
      {:ok, content} ->
        Benchee.run(%{"4-2" => fn -> process(content) end})
        final = process(content)
        IO.inspect(final)
      {:error, reason} ->
        IO.puts(reason)
    end
  end
end

Main.run()
