defmodule Optimus.Option do

  defstruct [
    :name,
    :value_name,
    :short,
    :long,
    :help,
    :multiple,
    :required,
    :parser
  ]

  def new(spec) do
    Optimus.Option.Builder.build(spec)
  end

  def parse(option, parsed, [item, raw_value | command_line]) do
    if option.short == item || option.long == item do
      key = {:option, option.name}
      if option.multiple || !Map.has_key?(parsed, key) do
        case option.parser.(raw_value) do
          {:ok, value} -> {:ok, Map.update(parsed, key, [value], &([value | &1])), command_line}
          {:error, reason} -> {:error, "invalid value #{inspect raw_value} for #{human_name(option)} option: #{reason}", command_line}
        end
      else
        {:error, "multiple occurences of option #{human_name(option)}", command_line}
      end
    else
      :skip
    end
  end
  def parse(_, _, _), do: :skip

  def try_match([option | options], parsed, items) do
    case parse(option, parsed, items) do
      :skip -> try_match(options, parsed, items)
      value -> value
    end
  end
  def try_match([], _, _), do: :skip

  def human_name(option) do
    case {option.long, option.short} do
      {long, nil} -> long
      {nil, short} -> short
      {long, short} -> "#{long}(#{short})"
    end
  end

end
