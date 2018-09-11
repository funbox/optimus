defmodule Optimus.Flag.Builder do
  alias Optimus.Flag
  alias Optimus.PropertyParsers, as: PP
  alias Optimus.Deps.Builder, as: DepsBuilder

  def build({name, props}) do
    case build_from_props(%Flag{name: name}, props) do
      {:ok, _arg} = res -> res
      {:error, reason} -> {:error, "invalid flag #{inspect(name)} properties: #{reason}"}
    end
  end

  defp build_from_props(flag, props) do
    with :ok <- validate_keyword_list(flag.name, props),
         {:ok, short} <- build_short(props),
         {:ok, long} <- build_long(props),
         {:ok, help} <- build_help(props),
         {:ok, multiple} <- build_multiple(props),
         {:ok, requires} <- build_deps(:requires, props),
         {:ok, conflicts} <- build_deps(:conflicts, props),
         {:ok, flag} <-
           validate(%Flag{
             flag
             | short: short,
               long: long,
               help: help,
               multiple: multiple,
               requires: requires,
               conflicts: conflicts
           }),
         do: {:ok, flag}
  end

  defp validate_keyword_list(name, list) do
    if Keyword.keyword?(list) do
      :ok
    else
      {:error, "properties for flag #{inspect(name)} should be a keyword list"}
    end
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

  def build_deps(key, props) do
    DepsBuilder.build(props[key])
  end

  defp validate(flag) do
    if flag.short || flag.long do
      {:ok, flag}
    else
      {:error, "neither :short nor :long form defined"}
    end
  end
end
