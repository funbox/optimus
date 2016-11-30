defmodule Optimus.ColumnFormatter do

  @type align :: :left | :center | :right
  @type column_spec :: pos_integer | {pos_integer, align}

  @spec format([column_spec], [String.t]) :: {:ok, [[String.t]]} | {:error, String.t}
  def format(column_specs, strings) do
    with :ok <- validate(column_specs, strings),
    do: {:ok, format_valid(column_specs, strings)}
  end

  defp format_valid(column_specs, strings) do
    column_specs
    |> Enum.zip(strings)
    |> Enum.map(fn {spec, string} -> {spec, split(string, width(spec))} end)
    |> to_lines
  end

  defp validate(column_specs, strings) do
    with :ok <- validate_lengths(column_specs, strings),
    :ok <- validate_strings(strings),
    :ok <- validate_specs(column_specs),
    do: :ok
  end

  defp validate_lengths(column_specs, strings) when is_list(column_specs) and is_list(strings) do
    if length(column_specs) == length(strings) do
      :ok
    else
      {:error, "arguments should have equal lengths"}
    end
  end
  defp validate_lengths(_, _), do: {:error, "arguments should be lists"}

  defp validate_strings([]), do: :ok
  defp validate_strings([string | strings]) do
    if is_binary(string) do
      validate_strings(strings)
    else
      {:error, "second argument is expected to be a list of strings"}
    end
  end

  defp validate_specs([]), do: :ok
  defp validate_specs([spec | specs]) do
    case spec do
      val when is_integer(val) and val > 0 -> validate_specs(specs)
      {val, align} when is_integer(val) and val > 0 and (align == :left or align == :center or align == :right) -> validate_specs(specs)
      _ -> {:error, "first argument is expected to be a list of width specs, where width spec is a positive integer or a tuple {width, align} where width is a positive integer and align is one of: :left, :center or :right"}
    end
  end

  defp split(string, max_width) do
    string
    |> String.graphemes
    |> split_graphemes(max_width, [])
  end

  defp to_lines(split_strings, converted \\ []) do
    {heads, rests} = heads_and_rests(split_strings, [], [])
    if have_nonempty?(heads) do
      line = to_line(heads, [])
      to_lines(rests, [line | converted])
    else
      Enum.reverse(converted)
    end
  end

  defp to_line([], converted) do
    converted
    |> Enum.reverse
  end
  defp to_line([head|heads], converted) do
    {spec, line_part} = head
    padded_line_part = pad(spec, line_part)
    to_line(heads, [padded_line_part | converted])
  end

  defp pad(spec, nil), do: spec |> width |> spaces
  defp pad(spec, {string_width, string}) do
    case align(spec) do
      :left ->
        padding_string = spaces(width(spec) - string_width)
        string <> padding_string
      :right ->
        padding_string = spaces(width(spec) - string_width)
        padding_string <> string
      :center ->
        padding_count = width(spec) - string_width
        left = div(padding_count, 2)
        right = padding_count - left
        spaces(left) <> string <> spaces(right)
    end
  end

  defp spaces(len) when is_integer(len) and len < 0, do: ""
  defp spaces(len) when is_integer(len) and len >= 0, do: String.duplicate(" ", len)

  defp heads_and_rests([], heads, rests), do: {Enum.reverse(heads), Enum.reverse(rests)}
  defp heads_and_rests([{spec, [string_head | string_rest]}| rest], heads, rests) do
    heads_and_rests(rest, [{spec, string_head}| heads], [{spec, string_rest}| rests])
  end
  defp heads_and_rests([{spec, []}| rest], heads, rests) do
    heads_and_rests(rest, [{spec, nil}| heads], [{spec, []}| rests])
  end

  defp width({w, _}), do: w
  defp width(w) when is_integer(w), do: w

  defp align({_, a}), do: a
  defp align(w) when is_integer(w), do: :left

  def split_graphemes([], _, already_split), do: Enum.reverse(already_split)
  def split_graphemes(graphemes, max_width, already_split) do
    {max_graphemes, rest} = Enum.split(graphemes, max_width)
    [head, tail] = if space_first?(rest) do
      [max_graphemes, []]
    else
      split_by_last_space_grapheme(max_graphemes)
    end

    {new_rest, current} = case head do
      [] -> {rest, tail} # failed to split
      _ -> {tail ++ rest, head}
    end

    formatted_current = current |> trim |> join_and_keep_width

    split_graphemes(new_rest, max_width, [formatted_current | already_split])
  end

  defp split_by_last_space_grapheme(list) do
    list
    |> Enum.reverse
    |> Enum.split_while(&not_space?/1)
    |> Tuple.to_list
    |> Enum.map(&Enum.reverse/1)
    |> Enum.reverse
  end

  defp trim(graphemes) do
    graphemes
    |> Enum.drop_while(&space?/1)
    |> Enum.reverse
    |> Enum.drop_while(&space?/1)
    |> Enum.reverse
  end

  def join_and_keep_width(graphemes) do
    {length(graphemes), Enum.join(graphemes)}
  end


  @space ~r/\A\s+\z/

  defp space?(grapheme) do
    grapheme =~ @space
  end

  defp not_space?(grapheme) do
    ! space?(grapheme)
  end

  defp space_first?([grapheme | _]), do: space?(grapheme)
  defp space_first?([]), do: true

  defp have_nonempty?(heads) do
    Enum.any?(heads, fn({_spec, head}) -> head != nil end)
  end

end
