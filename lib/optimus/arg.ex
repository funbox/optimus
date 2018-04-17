defmodule Optimus.Arg do
  defstruct [
    :name,
    :value_name,
    :help,
    :required,
    :parser
  ]

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
