defmodule OptimusTest do
  use ExUnit.Case

  test "minimal" do
    assert {:ok, _} = Optimus.new([])
  end

  test "invalid executable" do
    assert {:error, _} = Optimus.new(
      executable: 1
    )
  end

  test "invalid name" do
    assert {:error, _} = Optimus.new(
      name: 1
    )
  end

  test "invalid version" do
    assert {:error, _} = Optimus.new(
      version: 1
    )
  end

  test "invalid author" do
    assert {:error, _} = Optimus.new(
      version: 1
    )
  end

  test "invalid about" do
    assert {:error, _} = Optimus.new(
      about: 1
    )
  end

  test "invalid allow_extra_args" do
    assert {:error, _} = Optimus.new(
      allow_extra_args: "allow"
    )
  end

  test "invalid parse_double_dash" do
    assert {:error, _} = Optimus.new(
      parse_double_dash: "parse"
    )
  end

  test "minimal arg" do
    assert {:ok, _} = Optimus.new(
      args: [
        first: []
      ]
    )
  end

  test "arg: invalid value_name" do
    assert {:error, _} = Optimus.new(
      args: [
        first: [
          value_name: 1
        ]
      ]
    )
  end

  test "arg: invalid help" do
    assert {:error, _} = Optimus.new(
      args: [
        first: [
          help: 1
        ]
      ]
    )
  end

  test "arg: invalid required" do
    assert {:error, _} = Optimus.new(
      args: [
        first: [
          required: 1
        ]
      ]
    )
  end

  test "arg: invalid parser" do
    assert {:error, _} = Optimus.new(
      args: [
        first: [
          parser: :invalid
        ]
      ]
    )
  end

  test "arg: invalid required order" do
    assert {:error, _} = Optimus.new(
      args: [
        first: [
          required: false
        ],
        second: [
          required: true
        ]
      ]
    )
  end

  test "option: minimal" do
    assert {:ok, _} = Optimus.new(
      options: [
        first: [
          short: "-f"
        ]
      ]
    )
  end

  test "option: invalid short" do
    assert {:error, _} = Optimus.new(
      options: [
        first: [
          short: "-ff"
        ]
      ]
    )
  end

  test "option: invalid long" do
    assert {:error, _} = Optimus.new(
      options: [
        first: [
          long: "--lo ng"
        ]
      ]
    )
  end

  test "option: invalid help" do
    assert {:error, _} = Optimus.new(
      options: [
        first: [
          help: 1
        ]
      ]
    )
  end

  test "option: invalid parser" do
    assert {:error, _} = Optimus.new(
      options: [
        first: [
          parser: fn(_, _) -> {:ok, ""} end
        ]
      ]
    )
  end

  test "option: invalid required" do
    assert {:error, _} = Optimus.new(
      options: [
        first: [
          required: 1
        ]
      ]
    )
  end

  test "option: neither short nor long" do
    assert {:error, _} = Optimus.new(
      options: [
        first: []
      ]
    )
  end

  test "flag: minimal" do
    assert {:ok, _} = Optimus.new(
      flags: [
        first: [
          short: "-f"
        ]
      ]
    )
  end

  test "flag: invalid short" do
    assert {:error, _} = Optimus.new(
      flags: [
        first: [
          short: "-ff"
        ]
      ]
    )
  end

  test "flag: invalid long" do
    assert {:error, _} = Optimus.new(
      flags: [
        first: [
          long: "--lo ng"
        ]
      ]
    )
  end

  test "flag: invalid help" do
    assert {:error, _} = Optimus.new(
      flags: [
        first: [
          help: 1
        ]
      ]
    )
  end

  test "flag: invalid multiple" do
    assert {:error, _} = Optimus.new(
      flags: [
        first: [
          multiple: 1
        ]
      ]
    )
  end

  test "flag: neither short nor long" do
    assert {:error, _} = Optimus.new(
      flags: [
        first: []
      ]
    )
  end

  test "flag and option short name conflict" do
    assert {:error, _} = Optimus.new(
      flags: [
        options: [short: "-s"]
      ],
      options: [
        first: [short: "-s"]
      ]
    )
  end

  test "flag and option long name conflict" do
    assert {:error, _} = Optimus.new(
      flags: [
        options: [long: "--long"]
      ],
      options: [
        first: [long: "--long"]
      ]
    )
  end

  test "test full valid config" do
    assert {:ok, _} = Optimus.new(
      executable: "awesome",
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
          parser: :integer,
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
          parser: :string
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
          parser: :integer,
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
  end
end
