defmodule Optimus.TermTest do
  use ExUnit.Case

  test "width" do
    unless System.get_env("CI") do
      assert {:ok, n} = Optimus.Term.width()
      assert is_integer(n)
      assert n > 0
    end
  end
end
