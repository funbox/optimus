defmodule Optimus.Flag do

  defstruct [
    :name,
    :short,
    :long,
    :help,
    :multiple
  ]

  def new(spec) do
    Optimus.Flag.Builder.build(spec)
  end

  def parse(flag, parsed, [item | command_line]) do
    if flag.short == item || flag.long == item do
      key = {:flag, flag.name}
      if flag.multiple || !Map.has_key?(parsed, key) do
        {:ok, Map.update(parsed, key, 1, &(1 + &1)), command_line}
      else
        {:error, "multiple occurences of flag #{Optimus.Format.format_in_error(flag)}", command_line}
      end
    else
      :skip
    end
  end
  def parse(_, _, _), do: :skip

  def try_match([flag | flags], parsed, items) do
    case parse(flag, parsed, items) do
      :skip -> try_match(flags, parsed, items)
      value -> value
    end
  end
  def try_match([], _, _), do: :skip

end

defimpl Optimus.Format, for: Optimus.Flag do

  def format(flag) do
    [flag.short, flag.long]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(", ")
  end

  def format_in_error(flag) do
    case {flag.long, flag.short} do
      {long, nil} -> long
      {nil, short} -> short
      {long, short} -> "#{long}(#{short})"
    end
  end

  def format_in_usage(flag) do
    flag_name = flag.long || flag.short
    "[#{flag_name}]"
  end

  def help(flag), do: flag.help

end
