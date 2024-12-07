defmodule Day6 do
  def puzzle(content) do
    board =
      String.split(content, "\n")
      |> Enum.map(&String.to_charlist/1)

    rows = length(board)

    cols =
      hd(board)
      |> length()

    pos = find_guard_pos(board)
    visited = move(pos, :up, MapSet.new() |> MapSet.put(pos), board, rows, cols)
    IO.inspect(MapSet.size(visited))
  end

  def move(pos, direction, visited, board, rows, cols) do
    next_pos = next_pos(pos, direction)
    {i, j} = next_pos

    if i > rows - 1 || i < 0 || j > cols - 1 || j < 0 do
      visited
    else
      item = Enum.at(board, i) |> Enum.at(j)

      if item == ?# do
        move(pos, rotate(direction), visited, board, rows, cols)
      else
        move(next_pos, direction, visited |> MapSet.put(next_pos), board, rows, cols)
      end
    end
  end

  def rotate(direction) do
    case direction do
      :up -> :right
      :down -> :left
      :left -> :up
      :right -> :down
    end
  end

  def next_pos({i, j}, direction) do
    case direction do
      :up -> {i - 1, j}
      :down -> {i + 1, j}
      :left -> {i, j - 1}
      :right -> {i, j + 1}
    end
  end

  def find_guard_pos(board) do
    board
    |> Enum.with_index()
    |> Enum.find_value(fn {row, i} ->
      case Enum.find_index(row, fn cell -> cell == ?^ end) do
        nil -> nil
        j -> {i, j}
      end
    end)
  end
end

case File.read("input6.txt") do
  {:ok, content} -> Day6.puzzle(content)
  {:error, _} -> IO.puts("Failed to read file")
end
