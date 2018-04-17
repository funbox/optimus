defmodule Optimus.ColumnFormatterTest do
  use ExUnit.Case

  alias Optimus.ColumnFormatter, as: CF

  test "format: empty" do
    assert {:ok, _} = CF.format([], [])
  end

  test "format: invalid lengths" do
    assert {:error, _} = CF.format([], ["a"])
  end

  test "format: invalid strings" do
    assert {:error, _} = CF.format([1], [:a])
  end

  test "format: invalid specs" do
    assert {:error, _} = CF.format([:s], ["a"])
    assert {:error, _} = CF.format([-1], ["a"])
    assert {:error, _} = CF.format([{1, 2, 3}], ["a"])
    assert {:error, _} = CF.format([{-1, :left}], ["a"])
    assert {:error, _} = CF.format([{1, :top}], ["a"])
  end

  test "left" do
    assert {:ok, [["a b ", "  "], ["c d ", "  "]]} == CF.format([4, 2], [" a b c d", ""])
    assert {:ok, [["a b ", "  "], ["c d ", "  "]]} == CF.format([{4, :left}, 2], [" a b c d", ""])
  end

  test "right" do
    assert {:ok, [[" a b", "  "], [" c d", "  "]]} ==
             CF.format([{4, :right}, 2], [" a b c d", ""])
  end

  test "center" do
    assert {:ok, [[" a ", "  "], ["b c", "  "], [" d ", "  "]]} ==
             CF.format([{3, :center}, 2], [" a b c d", ""])
  end
end
