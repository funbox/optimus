defmodule Optimus.YamlLoader do
  def load(file_name) do
    _ = Application.start(:yamerl)
    safe_load(file_name)
  end

  defp safe_load(file_name) do
    try do
      {:ok, unsafe_load(file_name)}
    catch
      error -> {:error, error}
    end
  end

  defp unsafe_load(file_name) do
    :yamerl.decode_file(file_name, str_node_as_binary: true)
    |> List.last()
    |> map_keys()
  end

  defp map_keys({key, value}), do: {String.to_atom(key), map_keys(value)}
  defp map_keys(list) when is_list(list) do
    for entry <- list, do: map_keys(entry)
  end
  defp map_keys(val), do: val

end
