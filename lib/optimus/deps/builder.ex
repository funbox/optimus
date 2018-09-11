defmodule Optimus.Deps.Builder do
  alias Optimus.Deps

  @error "dependencies should be a keyword list [options: [:option1, :option2, ...], flags: [:flag1, :flag2, ...], args: [:arg1, :arg2, ...] ]"

  @keys [:args, :flags, :options]

  def build(props) when is_nil(props) do
    {:ok, %Deps{}}
  end

  def build(props_without_defaults) do
    props =
      Enum.reduce(@keys, props_without_defaults, fn key, st -> Keyword.put_new(st, key, []) end)

    with :ok <- validate(props), do: {:ok, struct(Deps, props)}
  end

  defp validate(props) do
    with true <- Keyword.keyword?(props),
         @keys <- props |> Keyword.keys() |> Enum.sort(),
         true <- is_list(props[:flags]),
         true <- @keys |> Enum.all?(&valid_value?(&1, props)) do
      :ok
    else
      _ -> {:error, @error}
    end
  end

  defp valid_value?(key, props) do
    value = props[key]
    is_list(value) && Enum.all?(value, &is_atom/1)
  end
end
