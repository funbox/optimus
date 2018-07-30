defmodule Optimus.TermTest do
  use ExUnit.Case

  test "width" do
    assert {:ok, n} = Optimus.Term.width()
    assert is_integer(n)
    assert n > 0
  end
end
