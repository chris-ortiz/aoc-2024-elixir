defmodule Day9 do
  def puzzle(content) do
    segments =
      String.to_charlist(content)
      |> Enum.with_index()
      |> Enum.flat_map(fn {c, index} ->
        character_count = c - ?0
        segment_val = if rem(index, 2) == 0, do: div(index, 2), else: -1

        if character_count > 0 do
          0..(character_count - 1)
          |> Enum.map(fn _ ->
            segment_val
          end)
        else
          []
        end
      end)

    IO.puts("working...")
    optimized_segments = fragment(0, 0, segments)
    IO.inspect(optimized_segments)
    IO.puts("done!")
  end

  def checksum(segments) do
    segments
    |> Enum.with_index()
    |> Enum.reduce(0, fn {segment, index}, acc ->
      if segment == -1 do
        acc
      else
        pos_times_index = index * segment
        acc + pos_times_index
      end
    end)
  end

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

  # part 1
  def fragment(i, j, segments) do
    if i >= j do
      segments
    else
      case Enum.at(segments, i) do
        -1 ->
          if Enum.at(segments, j) != -1 do
            new_list =
              replace(segments, i, Enum.at(segments, j))
              |> replace(j, -1)

            fragment(i + 1, j - 1, new_list)
          else
            fragment(i, j - 1, segments)
          end

        _ ->
          if Enum.at(segments, j) == -1 do
            fragment(i + 1, j - 1, segments)
          else
            fragment(i + 1, j, segments)
          end
      end
    end
  end

  def replace(list, i, new_value) do
    {before, [_old | after_old]} = Enum.split(list, i)
    before ++ [new_value] ++ after_old
  end
end

case File.read("input9.txt") do
  {:ok, content} -> Day9.puzzle(content)
  {:error, _} -> IO.puts("Failed to read file")
end
