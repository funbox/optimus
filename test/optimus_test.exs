defmodule OptimusTest do
  use ExUnit.Case

  test "test setup" do
    parser = Optimus.new(
      name: "Elixir App",
      version: "1.0.1",
      author: "Averyanov Ilya av@fun-box.ru",
      about: "Does awesome things",
      allow_extra_args: true,
      parse_double_dash: true,
      args: [
        first: [
          value_name: "FIRST",
          help: "First argument",
          required: true,
          type: :integer,
        ],
        second: [
          value_name: "SECOND",
          help: "Second argument",
          required: false,
          parser: fn(value) ->
              if value =~ ~r{\A(?:AA|BB|CC)\z} do
                {:ok, value}
              else
                {:error, "should be one of: AA, BB or CC"}
              end
          end
        ],
        third: [
          value_name: "THIRD",
          help: "Third argument",
          required: false,
          type: :string,
          default: "third"
        ]
      ],
      flags: [
        first_flag: [
          short: "f",
          long: "first-flag",
          help: "First flag",
          multiple: false,
        ],
        second_flag: [
          short: "s",
          long: "second-flag",
          help: "Second flag",
          multiple: true,
        ]
      ],
      options: [
        first_option: [
          value_name: "FIRST_OPTION",
          short: "o",
          long: "first-option",
          help: "First option",
          type: :integer,
          required: true
        ],
        second_option: [
          value_name: "SECOND_OPTION",
          short: "t",
          long: "second-option",
          help: "Second option",
          required: false,
          parser: fn(value) ->
              if value =~ ~r{\A(?:DD|EE|FF)\z} do
                {:ok, value}
              else
                {:error, "should be one of: DD, EE or FF"}
              end
          end
        ],
      ]
    )

    argv = ["123", "AA", "-f", "--second-flag", "-s", "-o", "123", "--second-option", "DD", "--", "thirdthird"]

    matches = Optimus.match!(parser, argv)
  end
end
