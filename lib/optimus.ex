defmodule Optimus do

  alias Optimus.Arg
  alias Optimus.Flag
  alias Optimus.Option

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
    Optimus.Builder.build(props)
  end

  def parse(optimus, command_line) do
    with :ok <- validate_command_line(command_line),
    {parsed, errors, unknown} <- parse_all_kinds({optimus.options, optimus.flags, optimus.args}, %{}, command_line, [], []),
    errors_with_unknown <- validate_unknown(optimus, unknown, errors),
    all_errors <- validate_required(optimus, parsed, errors_with_unknown),
    do: parse_result(optimus, parsed, unknown, all_errors)
  end

  def validate_command_line(command_line) when is_list(command_line) do
    if Enum.all?(command_line, &is_binary/1) do
      :ok
    else
      {:error, "list of strings expected"}
    end
  end
  def validate_command_line(_), do: {:error, "list of strings expected"}

  @end_of_flags_and_options "--"

  def parse_all_kinds(_, parsed, [], errors, unknown), do: {parsed, errors, unknown}
  def parse_all_kinds({options, flags, args} = parsers, parsed, [item | rest_items] = items, errors, unknown) do
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

  def parse_args([arg | args], parsed, [_ | _] = items, errors, unknown) do
    case Arg.parse(arg, parsed, items) do
      {:ok, new_parsed, new_items} -> parse_args(args, new_parsed, new_items, errors, unknown)
      {:error, error, new_items} -> parse_args(args, parsed, new_items, [error| errors], unknown)
    end
  end
  def parse_args([], parsed, [item | rest], errors, unknown), do: parse_args([], parsed, rest, errors, [item | unknown])
  def parse_args(_, parsed, [], errors, unknown), do: {parsed, errors, unknown}

  def validate_unknown(_optimus, [], errors), do: errors
  def validate_unknown(optimus, unknown, errors) do
    if optimus.allow_extra_args do
      errors
    else
      error = "unrecognized arguments: #{unknown |> Enum.map(&inspect/1) |> Enum.join(", ")}"
      [error | errors]
    end
  end

  def validate_required(optimus, parsed, errors) do
    missing_required_args = optimus.args
    |> Enum.reject(&Map.has_key?(parsed, &1.name))
    |> Enum.filter(&(&1.required))
    |> Enum.map(&(&1.value_name))

    missing_required_options = optimus.args
    |> Enum.reject(&Map.has_key?(parsed, &1.name))
    |> Enum.filter(&(&1.required))
    |> Enum.map(&Option.human_name(&1))

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

  def parse_result(optimus, parsed, unknown, []), do: {:ok, {optimus, parsed, unknown}}
  def parse_result(_optimus, _parsed, _unknown, errors), do: {:error, errors}

end
