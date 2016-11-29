defmodule Optimus do

  alias Optimus.Arg
  alias Optimus.Flag
  alias Optimus.Option

  defstruct [
    :name,
    :description,
    :version,
    :author,
    :about,
    :allow_unknown_args,
    :parse_double_dash,
    :args,
    :flags,
    :options,
    :subcommands,
    :subcommand
  ]

  defmodule ParseResult do
    defstruct [
      args: %{},
      flags: %{},
      options: %{},
      unknown: []
    ]
  end

  @type parser_result :: {:error, String.t} | {:ok, term}
  @type custom_parser :: (String.t -> parser_result)
  @type parser :: :integer | :float | :string | custom_parser

  @type arg_spec_item :: {:value_name, String.t} | {:help, String.t} | {:required, boolean} | {:parser, parser}
  @type arg_spec :: [arg_spec_item]

  @type flag_spec_item :: {:short, String.t} | {:long, String.t} | {:help, String.t} | {:multiple, boolean}
  @type flag_spec :: [flag_spec_item]

  @type option_spec_item :: {:value_name, String.t} | {:short, String.t} | {:long, String.t} | {:help, String.t} | {:multiple, boolean} | {:required, boolean} | {:parser, parser}
  @type option_spec :: [option_spec_item]

  @type spec_item :: {:name, String.t} | {:name, String.t} | {:version, String.t} | {:author, String.t} | {:about, String.t} | {:allow_unknown_args, boolean} | {:parse_double_dash, boolean} | {:args, [arg_spec]} | {:flags, [flag_spec]} | {:options, [option_spec]}
  @type spec :: [spec_item]

  @type error :: String.t
  @opaque optimus :: %Optimus{}

  @spec new(spec) :: {:ok, optimus} | {:error, [error]}
  def new(props) do
    props
    |> set_default_name
    |> Optimus.Builder.build
  end

  defp set_default_name(props) do
    if Keyword.keyword?(props) && props[:name] == nil do
      Keyword.put(props, :name, to_string(:escript.script_name))
    else
      props
    end
  end

  def parse(optimus, command_line) do
    with :ok <- validate_command_line(command_line),
    {sub_optimus, subcommand_path, sub_command_line} <- find_subcommand(optimus, [], command_line),
    {parsed, errors, unknown} <- parse_all_kinds({sub_optimus.options, sub_optimus.flags, sub_optimus.args}, %{}, sub_command_line, [], []),
    errors_with_unknown <- validate_unknown(sub_optimus, unknown, errors),
    all_errors <- validate_required(sub_optimus, parsed, errors_with_unknown),
    do: parse_result(sub_optimus, subcommand_path, parsed, unknown, all_errors)
  end

  defp get_arg(parsed, arg) do
    Map.get(parsed, {:arg, arg.name})
  end

  defp get_flag(parsed, flag) do
    case flag do
      %Flag{multiple: true} -> Map.get(parsed, {:flag, flag.name}, 0)
      _ -> if Map.get(parsed, {:flag, flag.name}), do: true, else: false
    end
  end

  defp get_option(parsed, option) do
    case option do
      %Option{multiple: true} ->
        parsed
        |> Map.get({:option, option.name}, [])
        |> Enum.reverse
      _ ->
        case Map.get(parsed, {:option, option.name}) do
          [val|_] -> val
          _ -> nil
        end
    end
  end

  # private functions

  defp validate_command_line(command_line) when is_list(command_line) do
    if Enum.all?(command_line, &is_binary/1) do
      :ok
    else
      {:error, "list of strings expected"}
    end
  end
  defp validate_command_line(_), do: {:error, "list of strings expected"}

  defp find_subcommand(optimus, path, []), do: {optimus, Enum.reverse(path), []}
  defp find_subcommand(optimus, path, [item | items] = command_line) do
    case Enum.find(optimus.subcommands, &(item == &1.name)) do
      %Optimus{} = sub_optimus -> find_subcommand(sub_optimus, [sub_optimus.subcommand | path], items)
      nil -> {optimus, Enum.reverse(path), command_line}
    end
  end

  @end_of_flags_and_options "--"

  defp parse_all_kinds(_, parsed, [], errors, unknown), do: {parsed, Enum.reverse(errors), Enum.reverse(unknown)}
  defp parse_all_kinds({options, flags, args} = parsers, parsed, [item | rest_items] = items, errors, unknown) do
    if item == @end_of_flags_and_options do
      parse_args(args, parsed, rest_items, errors, unknown)
    else
      case Option.try_match(options, parsed, items) do
        {:ok, new_parsed, new_items} -> parse_all_kinds(parsers, new_parsed, new_items, errors, unknown)
        {:error, error, new_items} -> parse_all_kinds(parsers, parsed, new_items, [error| errors], unknown)
        :skip ->
          case Flag.try_match(flags, parsed, items) do
            {:ok, new_parsed, new_items} -> parse_all_kinds(parsers, new_parsed, new_items, errors, unknown)
            {:error, error, new_items} -> parse_all_kinds(parsers, parsed, new_items, [error| errors], unknown)
            :skip ->
              case args do
                [arg | other_args] -> case Arg.parse(arg, parsed, items) do
                  {:ok, new_parsed, new_items} -> parse_all_kinds({options, flags, other_args}, new_parsed, new_items, errors, unknown)
                  {:error, error, new_items} -> parse_all_kinds({options, flags, other_args}, parsed, new_items, [error| errors], unknown)
                end
                [] ->
                  parse_all_kinds(parsers, parsed, rest_items, errors, [item | unknown])
              end
          end
      end
    end
  end

  defp parse_args([arg | args], parsed, [_ | _] = items, errors, unknown) do
    case Arg.parse(arg, parsed, items) do
      {:ok, new_parsed, new_items} -> parse_args(args, new_parsed, new_items, errors, unknown)
      {:error, error, new_items} -> parse_args(args, parsed, new_items, [error| errors], unknown)
    end
  end
  defp parse_args([], parsed, [item | rest], errors, unknown), do: parse_args([], parsed, rest, errors, [item | unknown])
  defp parse_args(_, parsed, [], errors, unknown), do: {parsed, Enum.reverse(errors), Enum.reverse(unknown)}

  defp validate_unknown(_optimus, [], errors), do: errors
  defp validate_unknown(optimus, unknown, errors) do
    if optimus.allow_unknown_args do
      errors
    else
      error = "unrecognized arguments: #{unknown |> Enum.map(&inspect/1) |> Enum.join(", ")}"
      [error | errors]
    end
  end

  def validate_required(optimus, parsed, errors) do
    missing_required_args = optimus.args
    |> Enum.reject(&Map.has_key?(parsed, {:arg, &1.name}))
    |> Enum.filter(&(&1.required))
    |> Enum.map(&Optimus.Format.format_in_error(&1))

    missing_required_options = optimus.options
    |> Enum.reject(&Map.has_key?(parsed, {:option, &1.name}))
    |> Enum.filter(&(&1.required))
    |> Enum.map(&Optimus.Format.format_in_error(&1))

    required_arg_error = case missing_required_args do
      [] -> []
      _ -> ["missing required arguments: #{missing_required_args |> Enum.join(", ")}"]
    end

    required_option_error = case missing_required_options do
      [] -> []
      _ -> ["missing required options: #{missing_required_options |> Enum.join(", ")}"]
    end

    required_arg_error ++ required_option_error ++ errors
  end

  defp parse_result(optimus, subcommand_path, parsed, unknown, []) do
    args = optimus.args
    |> Enum.map(fn(arg) -> {arg.name, get_arg(parsed, arg)} end)
    |> Enum.into(%{})

    flags = optimus.flags
    |> Enum.map(fn(flag) -> {flag.name, get_flag(parsed, flag)} end)
    |> Enum.into(%{})

    options = optimus.options
    |> Enum.map(fn(option) -> {option.name, get_option(parsed, option)} end)
    |> Enum.into(%{})

    parse_result = %ParseResult{args: args, flags: flags, options: options, unknown: unknown}
    case subcommand_path do
      [] -> {:ok, parse_result}
      [_|_] -> {:ok, subcommand_path, parse_result}
    end
  end
  defp parse_result(_optimus, subcommand_path, _parsed, _unknown, errors) do
    case subcommand_path do
      [] -> {:error, errors}
      [_|_] -> {:error, subcommand_path, errors}
    end
  end
end
