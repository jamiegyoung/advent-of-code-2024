defmodule Main do
  def char_indexes(content, char) do
    content
    |> Enum.with_index()
    |> Enum.filter(fn {c, _} -> c == char end)
    |> Enum.map(fn {_, i} -> i end)
  end

  defp extract_row_diagonal(row, ri, row_origin, col_origin, direction) do
    row
    |> Enum.with_index()
    |> Enum.reduce([], fn c_indexed, cacc ->
      case diagonal_value(ri, row_origin, direction, c_indexed, col_origin) do
        None -> cacc
        x -> [x | cacc]
      end
    end)
  end

  def extract_diagonal(matrix, row, col, direction) do
    matrix
    |> Enum.with_index()
    |> Enum.reduce([], fn {r, ri}, racc ->
      racc ++ extract_row_diagonal(r, ri, row, col, direction)
    end)
  end

  defp diagonal_value(ri, row_origin, direction, {c, ci}, col_origin) do
    if (ri - row_origin) * direction == ci - col_origin do
      # Mark the origin of the match with 1
      if ri - row_origin == 0 do
        1
      else
        c
      end
    else
      None
    end
  end

  def transpose(matrix) do
    Enum.zip_with(matrix, &Function.identity/1)
  end

  def charset_bidirectional_contains_count(char_list, charset) do
    char_list_string = Enum.join(char_list, "")
    charset_string = List.to_string(charset)
    forwards_contains = String.contains?(char_list_string, charset_string)
    backwards_contains = String.contains?(char_list_string, String.reverse(charset_string))

    Enum.reduce([forwards_contains, backwards_contains], 0, fn x, acc -> if x do acc + 1 else acc end end)
  end

  defp filter_row_to_matches(content, index, row_index, chars) do
    pos_diag = extract_diagonal(content, row_index, index, -1)
    neg_diag = extract_diagonal(content, row_index, index, 1)
    row = Enum.at(content, row_index)
      |> Enum.with_index()
      |> Enum.map(fn {x, i} -> if i == index do 1 else x end end)

    col = content
      |> transpose()
      |> Enum.at(index)
      |> Enum.with_index()
      |> Enum.map(fn {x, i} -> if i == row_index do 1 else x end end)

    Enum.reduce([pos_diag, neg_diag, row, col], 0, fn char_list, inner_acc ->
      inner_acc + charset_bidirectional_contains_count(char_list, chars)
    end)
  end

  def filter_to_matches(content, indexes, chars) do
    indexes_with_index = Enum.with_index(indexes)

    Enum.reduce(indexes_with_index, 0, fn {row_indexes, row_index}, acc ->
      Enum.reduce(row_indexes, acc, fn index, iacc ->
        iacc + filter_row_to_matches(content, index, row_index, chars)
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
      |> Enum.map(fn x -> char_indexes(x, "X") end)

    split_content
    |> filter_to_matches(indexes, ~c"1MAS")
  end

  def run() do
    case File.read("4.input") do
      {:ok, content} ->
        # Benchee.run(%{"4" => fn -> process(content) end})
        final = process(content)
        IO.inspect(final)
      {:error, reason} ->
        IO.puts(reason)
    end
  end
end

Main.run()
