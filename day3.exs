defmodule Day3 do
  def puzzle(content) do
    c = String.to_charlist(content)

    res =
      collect_tokens(c, [])
      |> Enum.reduce(0, fn {num1, num2}, acc -> acc + num1 * num2 end)

    IO.puts(res)
  end

  def collect_tokens(content, tokens) do
    case tokenize(content) do
      :eof ->
        tokens

      {num1, num2, remaining_content} ->
        collect_tokens(remaining_content, [{num1, num2} | tokens])
    end
  end

  def tokenize([]) do
    :eof
  end

  def tokenize([char | rest]) do
    case char do
      ?m ->
        case mul(rest) do
          :not_found ->
            tokenize(rest)

          res ->
            res
        end

      _ ->
        tokenize(rest)
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
