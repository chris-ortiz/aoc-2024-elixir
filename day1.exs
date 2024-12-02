{:ok, contents} = File.read("input1.txt")

{left, right} =
  contents
  |> String.split("\n", trim: true)
  |> Enum.map(fn line ->
    String.split(line, "\s\s\s")
  end)
  |> Enum.reduce({[], []}, fn [first, second], {acc1, acc2} ->
    {first, _} = Integer.parse(first)
    {second, _} = Integer.parse(second)

    {[first | acc1], [second | acc2]}
  end)
  |> then(fn {left, right} ->
    {Enum.sort(left), Enum.sort(right)}
  end)

distance =
  Enum.zip(left, right)
  |> Enum.map(fn {left, right} -> abs(left - right) end)
  |> Enum.sum()

IO.puts(distance)
