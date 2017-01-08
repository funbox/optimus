defmodule Optimus.Errors do

  def format(optimus, errors) do
    ["The following errors occured:"]
    ++ format_errors(errors)
    ++ [ "",
      "Try",
      "    #{optimus.name} --help",
      "",
      "to see available options",
      ""
    ]
  end

  def format(optimus, subcommand_path, errors) do
    {_subcommand, [_ | subcommand_name]} = Optimus.fetch_subcommand(optimus, subcommand_path)
    ["The following errors occured:"]
    ++ format_errors(errors)
    ++ [ "",
      "Try",
      "    #{optimus.name} help #{Enum.join(subcommand_name, " ")}",
      "",
      "to see available options",
      ""
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
