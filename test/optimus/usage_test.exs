defmodule Optimus.UsageTest do
  use ExUnit.Case

  alias Optimus.Usage

  def optimus do
    {:ok, optimus} =
      Optimus.new(
        name: "awesome",
        args: [
          first: [
            value_name: "FIRST",
            required: true
          ],
          second: [
            value_name: "SECOND",
            required: false
          ],
          third: [
            value_name: "THIRD",
            required: false
          ]
        ],
        flags: [
          first: [
            short: "f",
            long: "first-flag"
          ],
          second: [
            short: "s"
          ]
        ],
        options: [
          first: [
            value_name: "FIRST_OPTION",
            short: "o"
          ],
          second: [
            value_name: "SECOND_OPTION",
            short: "t",
            long: "second-option",
            required: true
          ]
        ],
        subcommands: [
          subcommand: [
            name: "subcommand",
            args: [first: []],
            flags: [first: [short: "-f"]],
            options: [first: [short: "-o"]]
          ]
        ]
      )

    optimus
  end

  test "usage: main command" do
    assert Usage.usage(optimus()) ==
             "awesome [--first-flag] [-s] [-o FIRST_OPTION] --second-option SECOND_OPTION FIRST [SECOND] [THIRD]"
  end

  test "usage: subcommand" do
    assert Usage.usage(optimus(), [:subcommand]) == "awesome subcommand [-f] [-o FIRST] FIRST"
  end

  test "usage: unknown args" do
    {:ok, optimus} =
      Optimus.new(
        name: "awesome",
        allow_unknown_args: true,
        args: [
          first: [
            value_name: "FIRST",
            required: true
          ],
          second: [
            value_name: "SECOND",
            required: false
          ],
          third: [
            value_name: "THIRD",
            required: false
          ]
        ]
      )

    assert Usage.usage(optimus) == "awesome FIRST [SECOND] [THIRD] ..."
  end
end
