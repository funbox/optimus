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
    @type arg_value :: term
    @type flag_value :: boolean | pos_integer
    @type option_value :: term | [term]

    @type t :: %ParseResult{
            args: %{atom => arg_value},
            flags: %{atom => flag_value},
            options: %{atom => option_value},
            unknown: [String.t()]
          }

    defstruct args: %{},
              flags: %{},
              options: %{},
              unknown: []
  end

  defmodule OptimusConfigurationError do
    defexception message: "invalid optimus configuration"
  end

  @type parser_result :: {:error, String.t()} | {:ok, term}
  @type custom_parser :: (String.t() -> parser_result)
  @type parser :: :integer | :float | :string | custom_parser

  @type arg_spec_param ::
          {:value_name, String.t()}
          | {:help, String.t()}
          | {:required, boolean}
          | {:parser, parser}
  @type arg_spec_item :: {name :: atom, [arg_spec_param]}

  @type flag_spec_param ::
          {:short, String.t()}
          | {:long, String.t()}
          | {:help, String.t()}
          | {:multiple, boolean}
  @type flag_spec_item :: {name :: atom, [flag_spec_param]}

  @type option_spec_param ::
          {:value_name, String.t()}
          | {:short, String.t()}
          | {:long, String.t()}
          | {:help, String.t()}
          | {:multiple, boolean}
          | {:required, boolean}
          | {:parser, parser}
          | {:default, any}
  @type option_spec_item :: {name :: atom, [option_spec_param]}

  @type spec_item ::
          {:name, String.t()}
          | {:description, String.t()}
          | {:version, String.t()}
          | {:author, String.t()}
          | {:about, String.t()}
          | {:allow_unknown_args, boolean}
          | {:parse_double_dash, boolean}
          | {:args, [arg_spec_item]}
          | {:flags, [flag_spec_item]}
          | {:options, [option_spec_item]}
  @type spec :: [spec_item]

  @type error :: String.t()
  @opaque t :: %Optimus{}

  @spec new(spec) :: {:ok, t} | {:error, [error]}
  def new(props) do
    props
    |> set_default_name
    |> Optimus.Builder.build()
  end

  @spec new!(spec) :: t | no_return
  def new!(props) do
    case new(props) do
      {:ok, optimus} ->
        optimus

      {:error, error} ->
        raise OptimusConfigurationError, message: "invalid optimus configuration: #{error}"
    end
  end

  @type subcommand_path :: [atom]

  @spec parse(t, [String.t()]) ::
          {:ok, ParseResult.t()}
          | {:ok, subcommand_path, ParseResult.t()}
          | {:error, [error]}
          | {:error, subcommand_path, [error]}
          | :version
          | :help
          | {:help, subcommand_path}
  def parse(optimus, command_line) do
    with :ok <- validate_command_line(command_line),
         :ok <- parse_specials(optimus, command_line),
         {sub_optimus, subcommand_path, sub_command_line} <-
           find_subcommand(optimus, [], command_line),
         {parsed, errors, unknown} <-
           parse_all_kinds(
             {sub_optimus.options, sub_optimus.flags, sub_optimus.args},
             %{},
             sub_command_line,
             [],
             []
           ),
         errors_with_unknown <- validate_unknown(sub_optimus, unknown, errors),
         all_errors <- validate_required(sub_optimus, parsed, errors_with_unknown),
         do: parse_result(sub_optimus, subcommand_path, parsed, unknown, all_errors)
  end

  @spec parse!(t, [String.t()], (integer -> no_return)) ::
          ParseResult.t() | {subcommand_path, ParseResult.t()} | no_return

  def parse!(optimus, command_line, halt \\ &System.halt/1) do
    case parse(optimus, command_line) do
      {:ok, parse_result} ->
        parse_result

      {:ok, subcommand_path, parse_result} ->
        {subcommand_path, parse_result}

      {:error, errors} ->
        optimus |> Optimus.Errors.format(errors) |> put_lines
        halt.(1)

      {:error, subcommand_path, errors} ->
        optimus |> Optimus.Errors.format(subcommand_path, errors) |> put_lines
        halt.(1)

      :version ->
        optimus |> Optimus.Title.title() |> put_lines
        halt.(0)

      :help ->
        optimus |> Optimus.Help.help([], columns()) |> put_lines
        halt.(0)

      {:help, subcommand_path} ->
        optimus |> Optimus.Help.help(subcommand_path, columns()) |> put_lines
        halt.(0)
    end
  end

  def help(optimus) do
    optimus
    |> Optimus.Help.help([], columns())
    |> Enum.join("\n")
  end

  defp columns do
    case Optimus.Term.width() do
      {:ok, width} -> width
      _ -> 80
    end
  end

  defp put_lines(lines) do
    lines
    |> Enum.map(&IO.puts/1)
  end

  defp parse_specials(_, ["--version"]), do: :version
  defp parse_specials(_, ["--help"]), do: :help

  defp parse_specials(optimus, ["help" | subcommand]) do
    case find_exact_subcommand(optimus, subcommand) do
      [_ | _] = subcommand_path -> {:help, subcommand_path}
      _ -> {:error, ["invalid subcommand: #{Enum.join(subcommand, " ")}"]}
    end
  end

  defp parse_specials(_, _), do: :ok

  defp find_exact_subcommand(optimus, subcommand, subcommand_path \\ [])
  defp find_exact_subcommand(_, [], found_path), do: Enum.reverse(found_path)

  defp find_exact_subcommand(optimus, [name | rest], found_path) do
    case Enum.find(optimus.subcommands, &(name == &1.name)) do
      %Optimus{subcommand: subcommand} = sub_optimus ->
        find_exact_subcommand(sub_optimus, rest, [subcommand | found_path])

      _ ->
        :error
    end
  end

  def fetch_subcommand(optimus, subcommand_path),
    do: fetch_subcommand(optimus, subcommand_path, [optimus.name])

  def fetch_subcommand(optimus, [], subcommand_name), do: {optimus, Enum.reverse(subcommand_name)}

  def fetch_subcommand(optimus, [subcommand_id | subcommand_path], subcommand_name) do
    subcommand = Enum.find(optimus.subcommands, &(subcommand_id == &1.subcommand))
    fetch_subcommand(subcommand, subcommand_path, [subcommand.name | subcommand_name])
  end

  # private functions

  defp set_default_name(props) do
    if Keyword.keyword?(props) && props[:name] == nil do
      Keyword.put(props, :name, to_string(:escript.script_name()))
    else
      props
    end
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
        default_value =
          if is_nil(option.default) do
            []
          else
            option.default
          end

        parsed
        |> Map.get({:option, option.name}, default_value)
        |> Enum.reverse()

      _ ->
        default_value =
          if is_nil(option.default) do
            nil
          else
            option.default
          end

        case Map.get(parsed, {:option, option.name}, default_value) do
          [val | _] -> val
          _ -> default_value
        end
    end
  end

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
      %Optimus{} = sub_optimus ->
        find_subcommand(sub_optimus, [sub_optimus.subcommand | path], items)

      nil ->
        {optimus, Enum.reverse(path), command_line}
    end
  end

  @end_of_flags_and_options "--"

  defp parse_all_kinds(_, parsed, [], errors, unknown),
    do: {parsed, Enum.reverse(errors), Enum.reverse(unknown)}

  defp parse_all_kinds(
         {options, flags, args} = parsers,
         parsed,
         [item | rest_items] = items,
         errors,
         unknown
       ) do
    if item == @end_of_flags_and_options do
      parse_args(args, parsed, rest_items, errors, unknown)
    else
      case Option.try_match(options, parsed, items) do
        {:ok, new_parsed, new_items} ->
          parse_all_kinds(parsers, new_parsed, new_items, errors, unknown)

        {:error, error, new_items} ->
          parse_all_kinds(parsers, parsed, new_items, [error | errors], unknown)

        :skip ->
          case Flag.try_match(flags, parsed, items) do
            {:ok, new_parsed, new_items} ->
              parse_all_kinds(parsers, new_parsed, new_items, errors, unknown)

            {:error, error, new_items} ->
              parse_all_kinds(parsers, parsed, new_items, [error | errors], unknown)

            :skip ->
              case args do
                [arg | other_args] ->
                  case Arg.parse(arg, parsed, items) do
                    {:ok, new_parsed, new_items} ->
                      parse_all_kinds(
                        {options, flags, other_args},
                        new_parsed,
                        new_items,
                        errors,
                        unknown
                      )

                    {:error, error, new_items} ->
                      parse_all_kinds(
                        {options, flags, other_args},
                        parsed,
                        new_items,
                        [error | errors],
                        unknown
                      )
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
      {:error, error, new_items} -> parse_args(args, parsed, new_items, [error | errors], unknown)
    end
  end

  defp parse_args([], parsed, [item | rest], errors, unknown),
    do: parse_args([], parsed, rest, errors, [item | unknown])

  defp parse_args(_, parsed, [], errors, unknown),
    do: {parsed, Enum.reverse(errors), Enum.reverse(unknown)}

  defp validate_unknown(_optimus, [], errors), do: errors

  defp validate_unknown(optimus, unknown, errors) do
    if optimus.allow_unknown_args do
      errors
    else
      error = "unrecognized arguments: #{unknown |> Enum.map(&inspect/1) |> Enum.join(", ")}"
      [error | errors]
    end
  end

  defp validate_required(optimus, parsed, []) do
    missing_required_args =
      optimus.args
      |> Enum.reject(&Map.has_key?(parsed, {:arg, &1.name}))
      |> Enum.filter(& &1.required)
      |> Enum.map(&Optimus.Format.format_in_error(&1))

    missing_required_options =
      optimus.options
      |> Enum.reject(&Map.has_key?(parsed, {:option, &1.name}))
      |> Enum.filter(& &1.required)
      |> Enum.map(&Optimus.Format.format_in_error(&1))

    required_arg_error =
      case missing_required_args do
        [] -> []
        _ -> ["missing required arguments: #{missing_required_args |> Enum.join(", ")}"]
      end

    required_option_error =
      case missing_required_options do
        [] -> []
        _ -> ["missing required options: #{missing_required_options |> Enum.join(", ")}"]
      end

    required_arg_error ++ required_option_error
  end

  defp validate_required(_optimus, _parsed, errors), do: errors

  defp parse_result(optimus, subcommand_path, parsed, unknown, []) do
    args =
      optimus.args
      |> Enum.map(fn arg -> {arg.name, get_arg(parsed, arg)} end)
      |> Enum.into(%{})

    flags =
      optimus.flags
      |> Enum.map(fn flag -> {flag.name, get_flag(parsed, flag)} end)
      |> Enum.into(%{})

    options =
      optimus.options
      |> Enum.map(fn option -> {option.name, get_option(parsed, option)} end)
      |> Enum.into(%{})

    parse_result = %ParseResult{args: args, flags: flags, options: options, unknown: unknown}

    case subcommand_path do
      [] -> {:ok, parse_result}
      [_ | _] -> {:ok, subcommand_path, parse_result}
    end
  end

  defp parse_result(_optimus, subcommand_path, _parsed, _unknown, errors) do
    case subcommand_path do
      [] -> {:error, errors}
      [_ | _] -> {:error, subcommand_path, errors}
    end
  end
end

defimpl Optimus.Format, for: Optimus do
  def format(optimus), do: optimus.name
  def format_in_error(optimus), do: optimus.name
  def format_in_usage(optimus), do: optimus.name

  def help(optimus), do: optimus.about || ""
end
