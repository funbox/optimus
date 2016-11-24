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
      {:ok, value} -> {:ok, Map.put(parsed, arg.name, value), command_line}
      {:error, reason} -> {:error, "invalid value #{inspect item} for #{arg.value_name}: #{reason}", command_line}
    end
  end


end
