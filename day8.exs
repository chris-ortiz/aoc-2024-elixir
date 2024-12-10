defmodule Day8 do
  def puzzle(content) do
    board =
      content
      |> String.split("\n")
      |> Enum.map(&String.to_charlist/1)

    antennas = parse_antennas(board)

    antinode_positions =
      antennas
      |> Map.keys()
      |> Enum.reduce(MapSet.new(), fn antenna, antinodes ->
        Map.get(antennas, antenna)
        |> get_pairs()
        |> Enum.reduce(antinodes, fn {pos1, pos2}, antinodes ->
          calc(pos1, pos2, length(board))
          |> Enum.filter(&valid_antinode?/1)
          |> Enum.reduce(antinodes, fn antinode, antinodes ->
            antinodes |> MapSet.put(antinode)
          end)
        end)
      end)

    IO.inspect(antinode_positions)
    IO.inspect(MapSet.size(antinode_positions))
  end

  def get_pairs(positions) do
    for i <- 0..(length(positions) - 2),
        j <- (i + 1)..(length(positions) - 1),
        reduce: [] do
      arr ->
        arr ++ [{Enum.at(positions, i), Enum.at(positions, j)}]
    end
  end

  def calc({i1, j1}, {i2, j2}, size) do
    {dist_row, dist_col} = {i2 - i1, abs(j2 - j1)}

    IO.puts("Calculating for:")
    IO.inspect({i1, j1})
    IO.inspect({i2, j2})

    if j2 > j1 do
      top_left_antinodes =
        Enum.zip((i1 - dist_row)..0//-dist_row, (j1 - dist_col)..0//-dist_col)
        |> Enum.reduce([], fn antinode, acc -> [antinode | acc] end)

      IO.puts("Top left:")
      IO.inspect(top_left_antinodes)

      bottom_right_antinodes =
        Enum.zip((i2 + dist_row)..size//dist_row, (j1 + dist_col)..size//dist_col)
        |> Enum.reduce([], fn antinode, acc -> [antinode | acc] end)

      IO.puts("Bottom right:")
      IO.inspect(bottom_right_antinodes)

      top_left_antinodes ++ bottom_right_antinodes
    else
      top_right_antinodes =
        Enum.zip((i1 - dist_row)..0//-dist_row, (j1 + dist_col)..size//dist_col)
        |> Enum.reduce([], fn antinode, acc -> [antinode | acc] end)

      IO.puts("Top right:")
      IO.inspect(top_right_antinodes)

      bottom_left_antinodes =
        Enum.zip((i2 + dist_row)..size//dist_row, (j2 - dist_col)..0//-dist_col)
        |> Enum.reduce([], fn antinode, acc -> [antinode | acc] end)

      IO.puts("Bottom left:")
      IO.inspect(bottom_left_antinodes)

      top_right_antinodes ++ bottom_left_antinodes
    end
  end

  def valid_antinode?({i, j}), do: valid_board_range(i) && valid_board_range(j)

  def valid_board_range(index), do: index >= 0 && index < 50

  def parse_antennas(board) do
    for i <- 0..(length(board) - 1),
        j <- 0..(length(hd(board)) - 1),
        reduce: %{} do
      res ->
        case Enum.at(board, i) |> Enum.at(j) do
          ?. ->
            res

          char ->
            {_, res} =
              Map.get_and_update(res, char, fn v ->
                if v == nil do
                  {v, [{i, j}]}
                else
                  {v, v ++ [{i, j}]}
                end
              end)

            res
        end
    end
  end
end

case File.read("input8-test.txt") do
  {:ok, content} -> Day8.puzzle(content)
  {:error, _} -> IO.puts("Failed to read file")
end
