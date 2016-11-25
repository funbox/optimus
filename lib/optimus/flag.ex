defmodule Optimus.Flag do

  defstruct [
    :name,
    :short,
    :long,
    :help,
    :multiple
  ]

  def new(spec) do
    Optimus.Flag.Builder.build(spec)
  end

  def parse(flag, parsed, [item | command_line]) do
    if flag.short == item || flag.long == item do
      if flag.multiple || !Map.has_key?(parsed, flag.name) do
        {:ok, Map.update(parsed, flag.name, 0, &(1 + &1)), command_line}
      else
        {:error, "multiple occurences of flag #{inspect flag.name}", command_line}
      end
    else
      :skip
    end
  end
  def parse(_, _, _), do: :skip

  def try_match([flag | flags], parsed, items) do
    case parse(flag, parsed, items) do
      :skip -> try_match(flags, parsed, items)
      value -> value
    end
  end
  def try_match([], _, _), do: :skip

end
