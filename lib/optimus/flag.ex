defmodule Optimus.Flag do
  alias Optimus.Flag
  alias Optimus.PropertyParsers, as: PP

  defstruct [
    :name,
    :short,
    :long,
    :help,
    :multiple
  ]

  def new({name, props}) when is_atom(name) do
    if Keyword.keyword?(props) do
        case parse_props(%Flag{name: name}, props) do
          {:ok, _arg} = res -> res
          {:error, reason} -> {:error, "invalid flag #{inspect name} properties: #{reason}"}
        end
    else
      {:error, "properties for flag #{inspect name} should be a keyword list"}
    end
  end

  defp parse_props(flag, props) do
    with {:ok, short} <- parse_short(props),
    {:ok, long} <- parse_long(props),
    {:ok, help} <- parse_help(props),
    {:ok, multiple} <- parse_multiple(props),
    {:ok, flag} <- validate(%Flag{flag| short: short, long: long, help: help, multiple: multiple}),
    do: {:ok, flag}
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

  defp validate(flag) do
    if flag.short || flag.long do
      {:ok, flag}
    else
      {:error, "neither :short nor :long form defined"}
    end
  end

end
