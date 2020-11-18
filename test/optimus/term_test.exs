defmodule Optimus.TermTest do
  use ExUnit.Case

  test "width" do
    case System.fetch_env("CI") do
      :error ->
        assert {:ok, n} = Optimus.Term.width()
        assert is_integer(n)
        assert n > 0
      {:ok, _} ->
        assert true
    end
  end
end
