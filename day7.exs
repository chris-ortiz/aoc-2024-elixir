defmodule Day7 do
  def puzzle(content) do
    equations = parse(content)
    sum = equations |> Enum.map(&calc/1) |> Enum.sum()
    IO.inspect(sum)
  end

  def concat(a, b) do
    (Integer.to_string(a) <> Integer.to_string(b))
    |> then(&Integer.parse/1)
    |> then(fn {i, _} -> i end)
  end

  def calc({expected_result, params}) do
    [first | rest] = params
    results = solve(first, rest)

    if Enum.any?(results, &(&1 == expected_result)) do
      expected_result
    else
      0
    end
  end

  def solve(current, rest) do
    case rest do
      [last] ->
        [current * last, current + last, concat(current, last)]

      [first | rest] ->
        solve(first * current, rest) ++
          solve(first + current, rest) ++
          solve(concat(current, first), rest)
    end
  end

  defp parse(content) do
    String.split(content, "\n")
    |> Enum.map(fn line ->
      String.split(line, ":", trim: true)
      |> then(fn [res, params] ->
        res = Integer.parse(res) |> then(fn {i, _} -> i end)

        params =
          String.split(params, " ", trim: true)
          |> Enum.map(fn i -> Integer.parse(i) |> then(fn {i, _} -> i end) end)

        {res, params}
      end)
    end)
  end
end

case File.read("input7.txt") do
  {:ok, content} -> Day7.puzzle(content)
  {:error, _} -> IO.puts("Failed to read file")
end
