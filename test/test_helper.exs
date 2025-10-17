ExUnit.start()
ExUnit.configure(exclude: [:skip])

defmodule OptimusTest.Helpers do
  def parse(optimus, items) do
    Optimus.parse!(optimus, items)
  end
end
