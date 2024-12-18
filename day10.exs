defmodule Day10 do
  def puzzle(content) do
    grid = parse_grid(content)

    max_rows = length(grid) - 1
    max_cols = length(hd(grid)) - 1

    count =
      for row <- 0..max_rows,
          col <- 0..max_cols,
          reduce: 0 do
        count ->
          height = Enum.at(grid, row) |> Enum.at(col)

          if height == 0 do
            trails =
              follow_trail(-1, grid, row, col, max_rows, max_cols, MapSet.new())
              |> Enum.uniq()
              |> Enum.count()

            # IO.inspect(trails)
            count + trails
          else
            count
          end
      end

    IO.inspect(count)
  end

  defp follow_trail(_, _, row, _, max_rows, _, _) when row > max_rows, do: []

  defp follow_trail(_, _, row, _, max_rows, _, _) when row < 0, do: []

  defp follow_trail(_, _, _, col, _, max_cols, _) when col < 0, do: []

  defp follow_trail(_, _, _, col, _, max_cols, _) when col > max_cols, do: []

  # startet with height 0, ends at height 9 with 1 or when breaking
  defp follow_trail(height_before, grid, row, col, max_rows, max_cols, visited) do
    if !MapSet.member?(visited, {row, col}) do
      visited = MapSet.put(visited, {row, col})
      height = Enum.at(grid, row) |> Enum.at(col)

      if height_before + 1 == height do
        case height do
          9 ->
            [{row, col}]

          _ ->
            follow_trail(height, grid, row, col - 1, max_rows, max_cols, visited) ++
              follow_trail(height, grid, row, col + 1, max_rows, max_cols, visited) ++
              follow_trail(height, grid, row - 1, col, max_rows, max_cols, visited) ++
              follow_trail(height, grid, row + 1, col, max_rows, max_cols, visited)
        end
      else
        []
      end
    else
      []
    end
  end

  defp parse_grid(content) do
    content
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.graphemes()
      |> Enum.map(fn grapheme ->
        Integer.parse(grapheme) |> then(fn {int, _} -> int end)
      end)
    end)
  end
end

case File.read("input10.txt") do
  {:ok, content} -> Day10.puzzle(content)
  {:error, _} -> IO.puts("Failed to read file")
end
