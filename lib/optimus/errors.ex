defmodule Optimus.Errors do

  def format(optimus, errors) do
    ["The following errors occured:"]
    ++ format_errors(errors)
    ++ [ "",
      "Try",
      "    #{optimus.name} --help",
      "to see available options"
    ]
  end

  def format_errors(errors) do
    Enum.map(
      errors,
      &[
        IO.ANSI.red,
        IO.ANSI.bright,
        "- #{&1}",
        IO.ANSI.reset
      ]
    )
  end
end
