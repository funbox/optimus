defmodule Optimus.Option do
  alias Optimus.Option
  alias Optimus.PropertyParsers, as: PP

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

  def new({name, props}) when is_atom(name) do
    if Keyword.keyword?(props) do
        case parse_props(%Option{name: name}, props) do
          {:ok, _arg} = res -> res
          {:error, reason} -> {:error, "invalid option #{inspect name} properties: #{reason}"}
        end
    else
      {:error, "properties for option #{inspect name} should be a keyword list"}
    end
  end

  defp parse_props(option, props) do
    with {:ok, value_name} <- parse_value_name(props, option.name),
    {:ok, short} <- parse_short(props),
    {:ok, long} <- parse_long(props),
    {:ok, help} <- parse_help(props),
    {:ok, multiple} <- parse_multiple(props),
    {:ok, required} <- parse_required(props),
    {:ok, parser} <- parse_parser(props),
    {:ok, option} <- validate(%Option{option| value_name: value_name, short: short, long: long, help: help, multiple: multiple, required: required, parser: parser}),
    do: {:ok, option}
  end

  defp parse_value_name(props, name) do
    default = name |> to_string |> String.upcase
    PP.parse_string(:value_name, props[:value_name], default)
  end

  defp parse_short(props) do
    PP.parse_short(:short, props[:short])
  end

  defp parse_long(props) do
    PP.parse_long(:long, props[:long])
  end

  defp parse_help(props) do
    PP.parse_string(:help, props[:help], "")
  end

  defp parse_multiple(props) do
    PP.parse_bool(:multiple, props[:multiple], false)
  end

  defp parse_required(props) do
    PP.parse_bool(:required, props[:required], false)
  end

  defp parse_parser(props) do
    PP.parse_parser(:parser, props[:parser])
  end

  defp validate(option) do
    if option.short || option.long do
      {:ok, option}
    else
      {:error, "neither :short nor :long form defined"}
    end
  end
end
