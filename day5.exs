defmodule Day5 do
  def puzzle(order, reports) do
    order =
      String.split(order, "\n")
      |> Enum.reduce(%{}, fn line, acc ->
        [a, b] = String.split(line, "|")
        Map.merge(acc, %{a => [b]}, fn k, v1, _ -> [b | v1] end)
      end)

    reports =
      String.split(reports, "\n")
      |> Enum.map(fn line -> String.split(line, ",") end)

    sum =
      reports
      |> Enum.map(fn report -> extract_middle(order, report) end)
      |> Enum.filter(fn v ->
        case v do
          nil -> false
          val -> true
        end
      end)
      |> Enum.map(fn val ->
        {i, _} = Integer.parse(val)
        i
      end)
      |> Enum.sum()

    IO.puts("Question 1: " <> Integer.to_string(sum))

    invalid_reports =
      reports
      |> Enum.filter(fn report ->
        index_map = Enum.with_index(report) |> Map.new()
        !is_report_valid?(order, index_map, report)
      end)
      |> Enum.map(fn report -> reorder(report, order) end)
      |> Enum.map(fn report -> Enum.at(report, floor(length(report) / 2)) end)
      |> Enum.map(&Integer.parse/1)
      |> Enum.map(fn {i, _} -> i end)
      |> Enum.sum()

    IO.puts("Question 2: " <> Integer.to_string(invalid_reports))
  end

  def reorder(report, order) do
    report
    |> Enum.sort(fn a, b ->
      index_map = Enum.with_index(report) |> Map.new()
      items_after_b = Map.get(order, b)

      if Enum.member?(items_after_b, a) do
        false
      else
        true
      end
    end)
  end

  def extract_middle(order, report) do
    index_map = Enum.with_index(report) |> Map.new()

    if is_report_valid?(order, index_map, report) do
      Enum.at(report, floor(length(report) / 2))
    else
      nil
    end
  end

  def is_report_valid?(order, index_map, report) do
    case Enum.find(report, :not_found, fn e ->
           follow_up_items = Map.get(order, e)
           current_index = Map.get(index_map, e)

           indices_of_follow_up_items =
             follow_up_items
             |> Enum.map(fn e -> Map.get(index_map, e) end)
             |> Enum.filter(fn e -> e != nil end)

           if has_follow_up_index_smaller?(indices_of_follow_up_items, current_index) do
             true
           else
             false
           end
         end) do
      :not_found -> true
      _ -> false
    end
  end

  def has_follow_up_index_smaller?(indices_of_follow_up_items, current_index) do
    case Enum.find(indices_of_follow_up_items, :not_found, fn i ->
           i < current_index
         end) do
      :not_found -> false
      _ -> true
    end
  end
end

with {:ok, order} <- File.read("input5_order.txt"),
     {:ok, reports} <- File.read("input5_reports.txt") do
  Day5.puzzle(order, reports)
else
  {:error, _} -> IO.puts("Failed to read files")
end
