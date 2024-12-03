defmodule Day2 do
  def puzzle(content) do
    safe_reports =
      pre_process(content)
      |> Enum.filter(fn levels ->
        if !is_safe(levels) do
          is_safe =
            0..(length(levels) - 1)
            |> Enum.any?(fn i ->
              sublist = List.delete_at(levels, i)
              is_safe(sublist)
            end)

          is_safe
        else
          true
        end
      end)
      |> Enum.count()

    IO.puts(safe_reports)
  end

  def is_safe(levels) do
    {_, _, is_safe} =
      levels
      |> Enum.reduce_while({nil, true, nil}, fn elem, {prev, direction, _} ->
        if prev == nil do
          {:cont, {elem, nil, true}}
        else
          current_direction = direction?(prev, elem)

          if direction != nil && current_direction != direction do
            {:halt, {elem, current_direction, false}}
          else
            if (prev < elem || prev > elem) && abs(elem - prev) < 4 do
              {:cont, {elem, current_direction, true}}
            else
              {:halt, {elem, current_direction, false}}
            end
          end
        end
      end)

    is_safe
  end

  def direction?(prev, elem) do
    if prev < elem do
      :ascending
    else
      :descending
    end
  end

  def pre_process(content) do
    String.split(content, "\n", trim: true)
    |> Enum.map(fn s ->
      String.split(s, "\s", trim: true)
      |> Enum.map(&Integer.parse/1)
      |> Enum.map(fn {i, _} -> i end)
    end)
  end
end

case File.read("input2.txt") do
  {:ok, content} -> Day2.puzzle(content)
  {:error, _} -> IO.puts("Failed to read file")
end
