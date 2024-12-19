defmodule Day11 do
  def puzzle(content) do
    stones = Parser.parse(content)

    stones_after_blinks =
      0..24
      |> Enum.reduce(stones, fn _, stones ->
        blink(stones)
      end)

    IO.inspect(length(stones_after_blinks))
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
