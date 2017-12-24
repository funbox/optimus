defmodule Optimus.Option do

  defstruct [
    :name,
    :value_name,
    :short,
    :long,
    :help,
    :multiple,
    :required,
    :default,
    :parser
  ]

  def new(spec) do
    Optimus.Option.Builder.build(spec)
  end

  def parse(option, parsed, command_line) when length(command_line) > 0 do
    case parse_option_parts(option, command_line) do
      {:ok, raw_value, rest} ->
        key = {:option, option.name}
        if option.multiple || !Map.has_key?(parsed, key) do
          case option.parser.(raw_value) do
            {:ok, value} -> {:ok, Map.update(parsed, key, [value], &([value | &1])), rest}
            {:error, reason} -> {:error, "invalid value #{inspect raw_value} for #{Optimus.Format.format_in_error(option)} option: #{reason}", rest}
          end
        else
          {:error, "multiple occurences of option #{Optimus.Format.format_in_error(option)}", rest}
        end
      :skip -> :skip
    end
  end
  def parse(_, _, _), do: :skip

  defp parse_option_parts(option, [item | items]) do
    case extract_value(option, item) do
      {:ok, value} -> {:ok, value, items}
      :none ->
        case items do
          [value_item | rest] ->
            if item == option.long or item == option.short do
              {:ok, value_item, rest}
            else
              :skip
            end
          _ -> :skip
        end
    end
  end

  defp extract_value(option, str) do
    if option.long do
      length = String.length(option.long) + 1
      if option.long <> "=" == String.slice(str, 0..length-1) do
        {:ok, String.slice(str, length..-1)}
      else
        :none
      end
    else
      :none
    end
  end

  def try_match([option | options], parsed, items) do
    case parse(option, parsed, items) do
      :skip -> try_match(options, parsed, items)
      value -> value
    end
  end
  def try_match([], _, _), do: :skip

end

defimpl Optimus.Format, for: Optimus.Option do

  def format(option) do
    [option.short, option.long]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(", ")
  end

  def format_in_error(option) do
    case {option.long, option.short} do
      {long, nil} -> long
      {nil, short} -> short
      {long, short} -> "#{long}(#{short})"
    end
  end

  def format_in_usage(option) do
    option_name = option.long || option.short
    if option.required do
      "#{option_name} #{option.value_name}"
    else
      "[#{option_name} #{option.value_name}]"
    end
  end

  def help(option) do
    help_string = option.help || ""

    if option.default do
      default_value_string =
        if is_list(option.default) do
          option.default |> Enum.map(&to_string/1) |> inspect
        else
          to_string(option.default)
        end
      "#{help_string} (default: #{default_value_string})"
    else
      help_string
    end
  end

end
