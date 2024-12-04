defmodule Day3 do
  def puzzle(content) do
    c = String.to_charlist(content)

    res =
      collect_tokens(c, [])
      |> Enum.reverse()
      |> Enum.reduce({0, true}, fn token, {sum, enabled} ->
        case token do
          {num1, num2} ->
            case enabled do
              true -> {sum + num1 * num2, true}
              false -> {sum, false}
            end

          :do ->
            {sum, true}

          :dont ->
            {sum, false}
        end
      end)

    IO.inspect(res)
  end

  def collect_tokens(content, tokens) do
    case tokenize(content) do
      :eof ->
        tokens

      {num1, num2, remaining_content} ->
        collect_tokens(remaining_content, [{num1, num2} | tokens])

      {do_or_dont, remaining_content} ->
        collect_tokens(remaining_content, [do_or_dont | tokens])
    end
  end

  def tokenize([]) do
    :eof
  end

  def tokenize([char | rest]) do
    case char do
      ?d ->
        with :not_found <- do_or_dont(rest) do
          tokenize(rest)
        else
          res -> res
        end

      ?m ->
        with :not_found <- mul(rest) do
          tokenize(rest)
        else
          res -> res
        end

      _ ->
        tokenize(rest)
    end
  end

  def do_or_dont(content) do
    case content do
      [?o, ?(, ?) | rest] ->
        {:do, rest}

      [?o, ?n, ?', ?t, ?(, ?) | rest] ->
        {:dont, rest}

      _ ->
        :not_found
    end
  end

  def mul(content) do
    case content do
      [?u, ?l, ?( | rest] ->
        extract_nums(rest)

      _ ->
        :not_found
    end
  end

  def extract_nums(content) do
    with {numbers, rest} <- Enum.split_while(content, fn c -> c != ?) end),
         {num1, num2} <- Enum.split_while(numbers, fn c -> c != ?, end) do
      try do
        {num1 |> List.to_integer(), num2 |> tl |> List.to_integer(), tl(rest)}
      rescue
        _ -> :not_found
      end
    else
      _ -> :not_found
    end
  end
end

case File.read("input3.txt") do
  {:ok, content} -> Day3.puzzle(content)
  {:error, _} -> IO.puts("Failed to read file")
end
