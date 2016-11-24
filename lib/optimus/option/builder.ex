defmodule Optimus.Option.Builder do
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

  def build({name, props}) do
    if Keyword.keyword?(props) do
        case build_from_props(%Option{name: name}, props) do
          {:ok, _arg} = res -> res
          {:error, reason} -> {:error, "invalid option #{inspect name} properties: #{reason}"}
        end
    else
      {:error, "properties for option #{inspect name} should be a keyword list"}
    end
  end

  defp build_from_props(option, props) do
    with {:ok, value_name} <- build_value_name(props, option.name),
    {:ok, short} <- build_short(props),
    {:ok, long} <- build_long(props),
    {:ok, help} <- build_help(props),
    {:ok, multiple} <- build_multiple(props),
    {:ok, required} <- build_required(props),
    {:ok, parser} <- build_parser(props),
    {:ok, option} <- validate(%Option{option| value_name: value_name, short: short, long: long, help: help, multiple: multiple, required: required, parser: parser}),
    do: {:ok, option}
  end

  defp build_value_name(props, name) do
    default = name |> to_string |> String.upcase
    PP.build_string(:value_name, props[:value_name], default)
  end

  defp build_short(props) do
    PP.build_short(:short, props[:short])
  end

  defp build_long(props) do
    PP.build_long(:long, props[:long])
  end

  defp build_help(props) do
    PP.build_string(:help, props[:help], "")
  end

  defp build_multiple(props) do
    PP.build_bool(:multiple, props[:multiple], false)
  end

  defp build_required(props) do
    PP.build_bool(:required, props[:required], false)
  end

  defp build_parser(props) do
    PP.build_parser(:parser, props[:parser])
  end

  defp validate(option) do
    if option.short || option.long do
      {:ok, option}
    else
      {:error, "neither :short nor :long form defined"}
    end
  end

end
