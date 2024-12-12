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
    optimized_segments = defragment(0, length(segments) - 1, segments)
    IO.inspect(optimized_segments)

    FileUtils.write_integers_to_file("segments_temp.txt", segments)
    FileUtils.write_integers_to_file("optimized_segments_temp.txt", optimized_segments)

    IO.inspect(checksum(optimized_segments))

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

  def defragment(i, j, segments) do
    if i >= j do
      IO.inspect(segments)
      segments
    else
      case Enum.at(segments, i) do
        -1 ->
          if Enum.at(segments, j) != -1 do
            new_list =
              fast_replace(segments, i, Enum.at(segments, j))
              |> fast_replace(j, -1)

            defragment(i + 1, j - 1, new_list)
          else
            defragment(i, j - 1, segments)
          end

        _ ->
          if Enum.at(segments, j) == -1 do
            defragment(i + 1, j - 1, segments)
          else
            defragment(i + 1, j, segments)
          end
      end
    end
  end

  def fast_replace(list, i, new_value) do
    {before, [_old | after_old]} = Enum.split(list, i)
    before ++ [new_value] ++ after_old
  end
end

defmodule FileUtils do
  @doc """
  Writes an array of integers to a file.

  ## Parameters
    - file_path: The path to the file where integers will be written
    - integers: A list of integers to be written to the file

  ## Returns
    - :ok if the file is successfully written
    - {:error, reason} if there's an error writing the file
  """
  def write_integers_to_file(file_path, integers) do
    # Convert integers to strings and join with newlines
    content =
      Enum.map(integers, &Integer.to_string/1)
      |> Enum.join("\n")

    # Write the content to the file
    File.write(file_path, content)
  end

  @doc """
  Writes an array of integers to a file with additional options.

  ## Parameters
    - file_path: The path to the file where integers will be written
    - integers: A list of integers to be written to the file
    - opts: A keyword list of additional options
      - encoding: The file encoding (default: :utf8)
      - append: Whether to append to the file (default: false)

  ## Returns
    - :ok if the file is successfully written
    - {:error, reason} if there's an error writing the file
  """
  def write_integers_to_file(file_path, integers, opts) do
    # Convert integers to strings and join with newlines
    content =
      Enum.map(integers, &Integer.to_string/1)
      |> Enum.join("\n")

    # Merge default options with provided options
    default_opts = [encoding: :utf8, append: false]
    final_opts = Keyword.merge(default_opts, opts)

    # Write the content to the file with specified options
    File.write(file_path, content, final_opts)
  end
end

case File.read("input9.txt") do
  {:ok, content} -> Day9.puzzle(content)
  {:error, _} -> IO.puts("Failed to read file")
end
