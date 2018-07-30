defmodule Optimus.Term do
  @moduledoc false

  @doc false
  def width do
    try do
      case System.cmd("tput", ["cols"]) do
        {width_str, 0} ->
          case Integer.parse(width_str) do
            {width, _} -> {:ok, width}
            :error -> {:error, "invalid tputs result"}
          end
        {error, _} -> {:error, "tputs error: #{error}"}
      end
    rescue
      error in ErlangError ->
        {:error, error.original}
    end
  end
end
