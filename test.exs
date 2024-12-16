defmodule Test do
  def size(segments, i, direction \\ :forward) do
    segments =
      case direction do
        :forward ->
          Enum.slice(segments, i, length(segments) - 1)

        :backwards ->
          Enum.split(segments, i + 1) |> then(fn {list, _} -> list end) |> Enum.reverse()
      end

    {_, length} =
      Enum.reduce_while(segments, {0, 1}, fn segment, {index, acc} ->
        if index < length(segments) &&
             segment == Enum.at(segments, index + 1) do
          {:cont, {index + 1, acc + 1}}
        else
          {:halt, {index, acc}}
        end
      end)

    length
  end

  def replace(segments, left_index, right_index, right_size) do
    new_val = Enum.at(segments, right_index)

    segments =
      for i <- left_index..(left_index + right_size - 1),
          reduce: segments do
        list ->
          list = List.replace_at(list, i, new_val)
          list
      end

    for i <- right_index..(right_index - right_size + 1)//-1,
        reduce: segments do
      list ->
        list = List.replace_at(list, i, -1)
        list
    end
  end
end

list = [
  0,
  0,
  -1,
  -1,
  -1,
  1,
  1,
  1,
  -1,
  -1,
  -1,
  2,
  -1,
  -1,
  -1,
  3,
  3,
  3,
  -1,
  9,
  9,
  -1,
  5,
  5,
  5,
  5,
  -1,
  6,
  6,
  6,
  6,
  -1,
  7,
  7,
  7,
  -1,
  8,
  8,
  8,
  8,
  9,
  9
]

# IO.inspect(length(list))
IO.inspect(list)
IO.inspect(Test.replace(list, 2, 41, 2))
