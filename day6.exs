defmodule Day6 do
  def puzzle(content) do
    board =
      String.split(content, "\n")
      |> Enum.map(&String.to_charlist/1)

    rows = length(board)

    cols =
      hd(board)
      |> length()

    start_pos = find_guard_pos(board)
    visited = move(start_pos, :up, MapSet.new() |> MapSet.put(start_pos), board, rows, cols)
    IO.inspect(MapSet.size(visited))

    {i_start, j_start} = start_pos

    stuck_positions =
      Enum.reduce(visited, 0, fn {i, j}, acc ->
        if {i, j} == start_pos || Enum.at(board, i) |> Enum.at(j) == ?# do
          acc
        else
          modified_board =
            List.update_at(board, i, fn row ->
              List.replace_at(row, j, ?#)
            end)

          case move_2(
                 start_pos,
                 :up,
                 MapSet.new() |> MapSet.put({i_start, j_start, :up}),
                 modified_board,
                 rows,
                 cols
               ) do
            :stuck -> acc + 1
            :not_stuck -> acc
          end
        end
      end)

    IO.inspect(stuck_positions)
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

  def move_2(pos, direction, visited, board, rows, cols) do
    next_pos = next_pos(pos, direction)
    {i, j} = next_pos

    if i > rows - 1 || i < 0 || j > cols - 1 || j < 0 do
      :not_stuck
    else
      if MapSet.member?(visited, {i, j, direction}) do
        :stuck
      else
        item = Enum.at(board, i) |> Enum.at(j)

        if item == ?# do
          new_direction = rotate(direction)

          {i, j} = pos

          move_2(
            pos,
            new_direction,
            visited |> MapSet.put({i, j, new_direction}),
            board,
            rows,
            cols
          )
        else
          move_2(next_pos, direction, visited |> MapSet.put({i, j, direction}), board, rows, cols)
        end
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
