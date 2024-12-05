defmodule Day4 do
  def puzzle(content) do
    board =
      content
      |> String.split("\n")
      |> Enum.map(&String.to_charlist/1)

    rows = length(board)
    cols = length(List.first(board))

    {count1, count2} =
      for i <- 0..(rows - 1),
          j <- 0..(cols - 1),
          reduce: {0, 0} do
        {count1, count2} ->
          current_char = Enum.at(board, i) |> Enum.at(j)

          case current_char do
            ?X ->
              search_count =
                [:up, :down, :left, :right, :right_up, :right_down, :left_up, :left_down]
                |> Enum.reduce(0, fn direction, acc ->
                  if search(~c"MAS", board, i, j, direction) do
                    acc + 1
                  else
                    acc
                  end
                end)

              {count1 + search_count, count2}

            ?M ->
              if search(~c"AS", board, i, j, :right_down) &&
                   ((Enum.at(board, i) |> Enum.at(j + 2) == ?S &&
                       search(~c"AM", board, i, j + 2, :left_down)) ||
                      (Enum.at(board, i) |> Enum.at(j + 2) == ?M &&
                         search(~c"AS", board, i, j + 2, :left_down))) do
                {count1, count2 + 1}
              else
                {count1, count2}
              end

            ?S ->
              if search(~c"AM", board, i, j, :right_down) &&
                   ((Enum.at(board, i) |> Enum.at(j + 2) == ?S &&
                       search(~c"AM", board, i, j + 2, :left_down)) ||
                      (Enum.at(board, i) |> Enum.at(j + 2) == ?M &&
                         search(~c"AS", board, i, j + 2, :left_down))) do
                {count1, count2 + 1}
              else
                {count1, count2}
              end

            _ ->
              {count1, count2}
          end
      end

    IO.puts("XMAS: " <> Integer.to_string(count1))
    IO.puts("X-MAS: " <> Integer.to_string(count2))
  end

  def search(search_term, board, i, j, direction) do
    {i, j} = index_by_direction(i, j, direction)

    if valid_board_index?(i, j, board) do
      current_char = Enum.at(board, i) |> Enum.at(j)

      case search_term do
        [^current_char] ->
          true

        [^current_char | rest] ->
          search(rest, board, i, j, direction)

        _ ->
          false
      end
    else
      false
    end
  end

  def index_by_direction(i, j, direction) do
    case direction do
      :down -> {i + 1, j}
      :up -> {i - 1, j}
      :left -> {i, j - 1}
      :right -> {i, j + 1}
      :right_up -> {i - 1, j + 1}
      :right_down -> {i + 1, j + 1}
      :left_up -> {i - 1, j - 1}
      :left_down -> {i + 1, j - 1}
    end
  end

  def valid_board_index?(i, j, board) do
    max_i = length(board) - 1
    max_j = length(hd(board)) - 1
    i >= 0 && i <= max_i && j >= 0 && j <= max_j
  end
end

case File.read("input4.txt") do
  {:ok, content} -> Day4.puzzle(content)
  {:error, _} -> IO.puts("Failed to read file")
end
