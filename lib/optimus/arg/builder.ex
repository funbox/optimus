defmodule Optimus.Arg.Builder do
  alias Optimus.Arg
  alias Optimus.PropertyParsers, as: PP
  alias Optimus.Deps.Builder, as: DepsBuilder

  def build({name, props}) do
    case build_from_props(%Arg{name: name}, props) do
      {:ok, _arg} = res -> res
      {:error, reason} -> {:error, "invalid argument #{inspect(name)} properties: #{reason}"}
    end
  end

  defp build_from_props(arg, props) do
    with :ok <- validate_keyword_list(arg.name, props),
         {:ok, value_name} <- build_value_name(props, arg.name),
         {:ok, help} <- build_help(props),
         {:ok, required} <- build_required(props),
         {:ok, parser} <- build_parser(props),
         {:ok, requires} <- build_deps(:requires, props),
         {:ok, conflicts} <- build_deps(:conflicts, props),
         do:
           {:ok,
            %Arg{
              arg
              | value_name: value_name,
                help: help,
                required: required,
                parser: parser,
                requires: requires,
                conflicts: conflicts
            }}
  end

  defp validate_keyword_list(name, list) do
    if Keyword.keyword?(list) do
      :ok
    else
      {:error, "properties for positional argument #{inspect(name)} should be a keyword list"}
    end
  end

  defp build_value_name(props, name) do
    default = name |> to_string |> String.upcase()
    PP.build_string(:value_name, props[:value_name], default)
  end

  defp build_help(props) do
    PP.build_string(:help, props[:help], "")
  end

  defp build_required(props) do
    PP.build_bool(:required, props[:required], true)
  end

  defp build_parser(props) do
    PP.build_parser(:parser, props[:parser])
  end

  def build_deps(key, props) do
    DepsBuilder.build(props[key])
  end
end
