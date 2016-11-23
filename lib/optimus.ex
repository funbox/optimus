defmodule Optimus do
  alias Optimus.PropertyParsers, as: PP

  defstruct [
    :name,
    :version,
    :author,
    :about,
    :allow_extra_args,
    :parse_double_dash,
    :args,
    :flags,
    :options
  ]

  def new(props) do
    if Keyword.keyword?(props) do
        case parse_props(props) do
          {:ok, _arg} = res -> res
          {:error, reason} -> {:error, "invalid configuration: #{reason}"}
        end
    else
      {:error, "#{__MODULE__}.new expects a keyword list"}
    end
  end

  def parse_props(props) do
    with {:ok, name} <- parse_name(props),
    {:ok, version} <- parse_version(props),
    {:ok, author} <- parse_author(props),
    {:ok, about} <- parse_about(props),
    {:ok, allow_extra_args} <- parse_allow_extra_args(props),
    {:ok, parse_double_dash} <- parse_parse_double_dash(props),
    {:ok, args} <- parse_args(props[:args]),
    {:ok, flags} <- parse_flags(props[:flags]),
    {:ok, options} <- parse_options(props[:options]),
    :ok <- validate_args(args),
    :ok <- validate_conflicts(flags, options),
    do: {:ok, %Optimus{name: name, version: version, author: author, about: about, allow_extra_args: allow_extra_args, parse_double_dash: parse_double_dash, args: args, flags: flags, options: options}}
  end

  defp parse_name(props) do
    PP.parse_string(:name, props[:name], nil)
  end

  defp parse_version(props) do
    PP.parse_string(:version, props[:version], nil)
  end

  defp parse_author(props) do
    PP.parse_string(:author, props[:author], nil)
  end

  defp parse_about(props) do
    PP.parse_string(:about, props[:about], nil)
  end

  defp parse_allow_extra_args(props) do
    PP.parse_bool(:allow_extra_args, props[:allow_extra_args], false)
  end

  defp parse_parse_double_dash(props) do
     PP.parse_bool(:parse_double_dash, props[:parse_double_dash], true)
  end

  defp parse_args(specs), do: parse_specs("args", Optimus.Arg, specs)
  defp parse_flags(specs), do: parse_specs("flags", Optimus.Flag, specs)
  defp parse_options(specs), do: parse_specs("options", Optimus.Option, specs)

  defp parse_specs(_name, _module, nil), do: []
  defp parse_specs(name, module, specs) do
    if Keyword.keyword?(specs) do
      parse_specs_(module, specs, [])
    else
      {:error, "#{name} specs are expected to be a Keyword list"}
    end
  end

  defp parse_specs_(_module, [], parsed), do: {:ok, Enum.reverse(parsed)}
  defp parse_specs_(module, [{_name, _props} = arg_spec | other], parsed) do
    with {:ok, arg} <- module.new(arg_spec),
    do: parse_specs_(module, other, [arg | parsed])
  end

  defp validate_args([arg1, arg2 | other]) do
    if !arg1.required && arg2.required do
      {:error, "required argument #{inspect arg2.name} follows optional argument #{inspect arg1.name}"}
    else
      validate_args([arg2 | other])
    end
  end

  defp validate_args(_), do: :ok

  defp validate_conflicts(flags, options) do
    with :ok <- validate_conflicts(flags, options, :short),
    :ok <- validate_conflicts(flags, options, :long),
    do: :ok
  end

  defp validate_conflicts(flags, options, key) do
    all_options = flags ++ options
    duplicate = all_options
    |> Enum.group_by(fn(item) -> Map.get(item, key) end, fn(item) -> item end)
    |> Map.to_list
    |> Enum.find(fn({_option_name, options}) -> length(options) > 1 end)

    case duplicate do
      {name, _} -> {:error, "duplicate #{key} option name: #{name}"}
      nil -> :ok
    end

  end

end
