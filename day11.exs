defmodule Day11 do
  def puzzle(content) do
    stones = Parser.parse(content)

    part1(stones)
    part2(stones)
  end

  def part2(stones) do
    stones = stones |> Enum.map(&{&1, 1}) |> Map.new()

    stones =
      0..74
      |> Enum.reduce(stones, fn _, stones ->
        blink_part2(stones)
      end)

    sum = Map.values(stones) |> Enum.sum()

    IO.puts("Part 2: #{sum}, Keys: #{length(Map.keys(stones))}")
  end

  def part1(stones) do
    stones_after_blinks =
      0..24
      |> Enum.reduce(stones, fn _, stones ->
        blink(stones)
      end)

    IO.puts("Part 1: #{length(stones_after_blinks)}")
  end

  def blink_part2(stones) do
    stones
    |> Enum.reduce(Map.new(), fn {stone, count_before}, stones ->
      case apply_rules(stone) do
        [stone1, stone2] ->
          stones
          |> Map.update(stone1, count_before, fn count -> count + count_before end)
          |> Map.update(stone2, count_before, fn count -> count + count_before end)

        stone ->
          stones
          |> Map.update(stone, count_before, fn count -> count + count_before end)
      end
    end)
  end

  def blink(stones) do
    stones
    |> Enum.map(&apply_rules/1)
    |> Enum.flat_map(fn
      e when is_list(e) -> e
      e -> [e]
    end)
  end

  def apply_rules(stone) do
    digits = Integer.digits(stone)

    digits_length = length(digits)

    even_number_of_digits =
      digits_length
      |> rem(2) == 0

    case stone do
      0 ->
        1

      _ when even_number_of_digits ->
        {first_half, second_half} = Enum.split(digits, div(digits_length, 2))
        [Integer.undigits(first_half), Integer.undigits(second_half)]

      _ ->
        stone * 2024
    end
  end
end

defmodule Parser do
  def parse(content) do
    content
    |> String.split(" ")
    |> Enum.map(fn stone ->
      Integer.parse(stone)
      |> then(fn {int, _} -> int end)
    end)
  end
end

Day11.puzzle("5 62914 65 972 0 805922 6521 1639064")
