defmodule Optimus.Arg do
  @moduledoc """
  Represents a positional command line argument.

  Arguments are positional parameters that are required or optional.
  They can be parsed into various types using a parser function.
  """

  @typedoc "Argument structure"
  @type t :: %__MODULE__{
          name: atom(),
          value_name: String.t(),
          help: String.t() | nil,
          required: boolean(),
          parser: (String.t() -> {:ok, term()} | {:error, String.t()})
        }

  defstruct name: nil,
            value_name: nil,
            help: nil,
            required: false,
            parser: nil

  def new(spec) do
    Optimus.Arg.Builder.build(spec)
  end

  def parse(arg, parsed, [item | command_line]) do
    case arg.parser.(item) do
      {:ok, value} ->
        {:ok, Map.put(parsed, {:arg, arg.name}, value), command_line}

      {:error, reason} ->
        {:error, "invalid value #{inspect(item)} for #{arg.value_name}: #{reason}", command_line}
    end
  end
end

defimpl Optimus.Format, for: Optimus.Arg do
  def format(arg), do: arg.value_name

  def format_in_error(arg), do: arg.value_name

  def format_in_usage(arg) do
    if arg.required do
      arg.value_name
    else
      "[#{arg.value_name}]"
    end
  end

  def help(arg), do: arg.help || ""
end
