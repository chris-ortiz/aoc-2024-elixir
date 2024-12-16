defmodule Day9 do
  def puzzle(content) do
    input =
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

    defragment(input)
    IO.puts("done!")
  end

  # part 2
  def defragment(input) do
    # first create overview of empty blocks and files + their location + size
    {empty_blocks, files} =
      input
      |> Enum.reduce({[], [], 0}, fn block, {empty_blocks, files, index} ->
        case block do
          -1 ->
            empty_blocks =
              case empty_blocks do
                [{index_last, length} | tail] when index_last == index - length ->
                  [{index_last, length + 1}] ++ tail

                [] ->
                  [{index, 1}]

                list ->
                  [{index, 1}] ++ list
              end

            {empty_blocks, files, index + 1}

          file_id ->
            files =
              case files do
                [{index, last_file_id, length} | tail] when last_file_id == file_id ->
                  [{index, file_id, length + 1} | tail]

                _ ->
                  [{index, file_id, 1} | files]
              end

            {empty_blocks, files, index + 1}
        end
      end)
      |> then(fn {empty_blocks, files, _} -> {Enum.reverse(empty_blocks), files} end)

    {empty_blocks, files} =
      for file <- files,
          reduce: {empty_blocks, files} do
        {empty_blocks, files} ->
          {file_index, file_id, file_size} = file

          case next_fitting_empty_block(empty_blocks, file_size, file_index) do
            nil ->
              [_ | files] = files
              {empty_blocks, files ++ [file]}

            {empty_block, remaining_empty_blocks} ->
              [_ | remaining_files] = files

              case swap(empty_block, file) do
                {[leftover, empty_block], file} ->
                  empty_blocks =
                    ([leftover] ++ [empty_block] ++ remaining_empty_blocks) |> Enum.sort()

                  files = remaining_files ++ [file]
                  {empty_blocks, files}

                {empty_block, file} ->
                  empty_blocks = [empty_block] ++ remaining_empty_blocks
                  files = remaining_files ++ [file]
                  {empty_blocks, files}
              end
          end
      end

    result = convert_to_disk(empty_blocks, files)
    IO.inspect(checksum(result))
  end

  def convert_to_disk(empty_blocks, files) do
    (empty_blocks ++ files)
    |> Enum.sort_by(fn
      {index, _, _} ->
        index

      {index, _} ->
        index
    end)
    |> Enum.flat_map(fn block ->
      case block do
        {file_index, file_id, file_size} -> List.duplicate(file_id, file_size)
        {index, size} -> List.duplicate(-1, size)
      end
    end)
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

  defp swap({empty_block_index, empty_size}, {file_index, file_id, file_size}) do
    leftover_size = empty_size - file_size

    if leftover_size > 0 do
      {[{empty_block_index + file_size, leftover_size}, {file_index, file_size}],
       {empty_block_index, file_id, file_size}}
    else
      {{file_index, empty_size}, {empty_block_index, file_id, file_size}}
    end
  end

  defp next_fitting_empty_block(empty_blocks, size, max_index) do
    {matches, remaining} =
      empty_blocks
      |> Enum.sort()
      |> Enum.split_with(fn {index, empty_size} -> empty_size >= size && index < max_index end)

    case matches do
      [] -> nil
      [first | rest] -> {first, remaining ++ rest}
    end
  end

  defp print(segments) do
    segments
    |> Enum.each(fn element ->
      if element == -1 do
        IO.write(".")
      else
        IO.write(element)
      end
    end)

    IO.write("\n")
  end

  defp get_indices(empty_segments, size_right) do
    Map.keys(empty_segments)
    |> Enum.sort()
    |> Enum.filter(fn size ->
      size_right <= size && length(Map.get(empty_segments, size)) > 0
    end)
    |> Enum.flat_map(fn size ->
      Map.get(empty_segments, size)
      |> Enum.map(fn indices -> {indices, size} end)
    end)
    |> Enum.sort()
  end

  defp get_empty_segments(segments) do
    segments
    |> Enum.with_index()
    |> Enum.filter(fn {segment, _} -> hd(segment) == -1 end)
    |> Enum.map(fn swi -> {length(elem(swi, 0)), elem(swi, 1)} end)
    |> Enum.group_by(fn {i, _} -> i end, fn {_, e} -> e end)
    |> Map.new()
  end
end

case File.read("input9.txt") do
  {:ok, content} -> Day9.puzzle(content)
  {:error, _} -> IO.puts("Failed to read file")
end
