defmodule OptimusTest do
  use ExUnit.Case

  test "minimal" do
    assert {:ok, _} = Optimus.new([])
  end

  test "invalid name" do
    assert {:error, _} = Optimus.new(
      name: 1
    )

    assert {:error, _} = Optimus.new(
      name: "name with spaces"
    )

  end

  test "invalid description" do
    assert {:error, _} = Optimus.new(
      description: 1
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

  test "invalid allow_unknown_args" do
    assert {:error, _} = Optimus.new(
      allow_unknown_args: "allow"
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

  test "invalid subcommand" do
    assert {:error, _} = Optimus.new(
      subcommands: [
        subcommand: [
          options: [
            first: [long: "--lo ng"]
          ]
        ]
      ]
    )
  end

  def full_valid_config, do: [
    name: "awesome",
    description: "Elixir App",
    version: "1.0.1",
    author: "Averyanov Ilya av@fun-box.ru",
    about: "Does awesome things",
    allow_unknown_args: true,
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
      first: [
        short: "f",
        long: "first-flag",
        help: "First flag",
        multiple: false,
      ],
      second: [
        short: "s",
        long: "second-flag",
        help: "Second flag",
        multiple: true,
      ]
    ],
    options: [
      first: [
        value_name: "FIRST_OPTION",
        short: "o",
        long: "first-option",
        help: "First option",
        parser: :integer,
        required: true
      ],
      second: [
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
    ],
    subcommands: [
      subcommand: [
        name: "subcommand",
        description: "Elixir App",
        about: "Does awesome things",
        allow_unknown_args: false,
        parse_double_dash: false,
        args: [first: []],
        flags: [first: [short: "-f"]],
        options: [first: [short: "-o", parser: :integer]]
      ]
    ]
  ]

  test "test full valid config" do
    assert {:ok, _} = Optimus.new(full_valid_config)
  end

  test "parse: check format for arg" do
    {:ok, optimus} = Optimus.new(
      args: [
        first: [
          parser: :integer
        ]
      ]
    )
    assert {:error, _} = Optimus.parse(optimus, ~w{not_an_int})
    assert {:ok, _} = Optimus.parse(optimus, ~w{123})

    {:ok, optimus} = Optimus.new(
      args: [
        first: [
          parser: fn(val) -> case val do
            "VAL" -> {:ok, "VAL"}
            _ -> {:error, "val should be \"VAL\""}
          end end
        ]
      ]
    )
    assert {:error, _} = Optimus.parse(optimus, ~w{not_VAL})
    assert {:ok, _} = Optimus.parse(optimus, ~w{VAL})
  end

  test "parse: check format for option" do
    {:ok, optimus} = Optimus.new(
      options: [
        first: [
          short: "-f",
          parser: :integer
        ]
      ]
    )
    assert {:error, _} = Optimus.parse(optimus, ~w{-f not_an_int})
    assert {:ok, _} = Optimus.parse(optimus, ~w{-f 123})

    {:ok, optimus} = Optimus.new(
      options: [
        first: [
          short: "-f",
          parser: fn(val) ->
            case val do
              "VAL" -> {:ok, "VAL"}
              _ -> {:error, "val should be \"VAL\""}
            end
          end
        ]
      ]
    )
    assert {:error, _} = Optimus.parse(optimus, ~w{-f not_VAL})
    assert {:ok, _} = Optimus.parse(optimus, ~w{-f VAL})
  end

  test "parse: check multiple occurences for option" do
    {:ok, optimus} = Optimus.new(
      options: [
        first: [
          short: "-f",
          multiple: true,
          required: true
        ],
        second: [
          short: "-s",
          multiple: false,
          required: true
        ]
      ]
    )
    assert {:error, _} = Optimus.parse(optimus, ~w{-f a -s b -s c})
    assert {:ok, _} = Optimus.parse(optimus, ~w{-f a -f b -s c})
  end

  test "parse: check multiple occurences for flag" do
    {:ok, optimus} = Optimus.new(
      flags: [
        first: [
          short: "-f",
          multiple: true
        ],
        second: [
          short: "-s",
          multiple: false
        ]
      ]
    )
    assert {:error, _} = Optimus.parse(optimus, ~w{-s -s})
    assert {:ok, _} = Optimus.parse(optimus, ~w{-f -f})
  end

  test "parse: invalid command line" do
    {:ok, optimus} = Optimus.new(allow_unknown_args: true)
    assert {:error, _} = Optimus.parse(optimus, [1, 2, 3])
  end

  test "parse: unrecognized arguments" do
    {:ok, optimus} = Optimus.new(
      args: [
        first: []
      ]
    )
    assert {:ok, _} = Optimus.parse(optimus, ~w{a1})
    assert {:error, _} = Optimus.parse(optimus, ~w{a1 a2})

    {:ok, optimus} = Optimus.new(
      allow_unknown_args: true,
      args: [
        first: []
      ]
    )
    assert {:ok, _} = Optimus.parse(optimus, ~w{a1 a2})
  end

  test "parse: missing required args" do
    {:ok, optimus} = Optimus.new(
      args: [
        first: [required: true]
      ]
    )

    assert {:ok, _} = Optimus.parse(optimus, ~w{a1})
    assert {:error, _} = Optimus.parse(optimus, ~w{})
  end

  test "parse: missing required options" do
    {:ok, optimus} = Optimus.new(
      options: [
        first: [required: true, short: "-f"]
      ]
    )

    assert {:ok, _} = Optimus.parse(optimus, ~w{-f a1})
    assert {:error, _} = Optimus.parse(optimus, ~w{})
  end

  test "parse: check subcommand" do
    {:ok, optimus} = Optimus.new(
      subcommands: [
        first: [
          name: "s1",
          subcommands: [
            second: [
              name: "s2",
              options: [o: [short: "-o", parser: :integer]]
            ]
          ]
        ]
      ]
    )
    assert {:error, [:first, :second], _} = Optimus.parse(optimus, ~w{s1 s2 -o not_an_int})
  end

  test "parse: full configuration" do
    assert {:ok, optimus} = Optimus.new(full_valid_config)
    command_line = ~w{123 AA -f --second-flag -s -o 123 --second-option DD -- thirdthird --fourth}
    assert {:ok, _} = Optimus.parse(optimus, command_line)
  end

  test "parse: args" do
    assert {:ok, optimus} = Optimus.new(args: [
      first: [parser: :integer],
      second: [parser: :float],
      third: [parser: :string],
      fourth: [],
      fifth: [parser: fn(val) -> {:ok, val <> val} end]
    ])
    command_line = ~w{123 2.5 third fourth fifth}
    assert {:ok, parsed} = Optimus.parse(optimus, command_line)

    assert 123 == parsed.args[:first]
    assert 2.5 == parsed.args[:second]
    assert "third" == parsed.args[:third]
    assert "fourth" == parsed.args[:fourth]
    assert "fifthfifth" == parsed.args[:fifth]
  end

  test "parse: flags" do
    assert {:ok, optimus} = Optimus.new(flags: [
        first: [short: "-f"],
        second: [long: "--second"],
        third: [short: "-t", long: "--third", multiple: true],
        fourth: [long: "--fourth", multiple: true],
        fifth: [long: "--fifth"]
    ])
    command_line = ~w{-f --second -t --third}
    assert {:ok, parsed} = Optimus.parse(optimus, command_line)
    assert true == parsed.flags[:first]
    assert true == parsed.flags[:second]
    assert 2 == parsed.flags[:third]
    assert 0 == parsed.flags[:fourth]
    assert false == parsed.flags[:fifth]
  end

  test "parse: options" do
    assert {:ok, optimus} = Optimus.new(options: [
        first: [short: "-f", parser: :integer],
        second: [long: "--second", parser: :float],
        third: [short: "-t", long: "--third", multiple: true, parser: fn(val) -> {:ok, {val}} end],
        fourth: [long: "--fourth", multiple: true, required: false],
        fifth: [long: "--fifth", required: false]
    ])
    command_line = ~w{-f 123 --second 2.5 -t a --third b}
    assert {:ok, parsed} = Optimus.parse(optimus, command_line)

    assert 123 == parsed.options[:first]
    assert 2.5 == parsed.options[:second]
    assert [{"a"}, {"b"}] == parsed.options[:third]
    assert [] == parsed.options[:fourth]
    assert nil == parsed.options[:fifth]
  end

  test "parse: unknown" do
    assert {:ok, optimus} = Optimus.new(
      allow_unknown_args: true,
      args: [first: []],
      flags: [first: [short: "-f"]],
      options: [first: [short: "-o"]]
    )

    command_line = ~w{a -f b -o o c -- d}
    assert {:ok, parsed} = Optimus.parse(optimus, command_line)
    assert ~w{b c d} == parsed.unknown
  end

  test "parse: subcommand" do
    assert {:ok, optimus} = Optimus.new(
      subcommands: [
        sub: [
          name: "sub",
          args: [first: []],
          flags: [first: [short: "-f"]],
          options: [first: [short: "-o"]]
        ]
      ]
    )

    assert {:ok, [:sub], parsed} = Optimus.parse(optimus, ~w{sub a -f -o o})
    assert "a" == parsed.args[:first]
    assert true == parsed.flags[:first]
    assert "o" == parsed.options[:first]
  end

  test "parse: --version" do
    {:ok, optimus} = Optimus.new([])
    assert :version == Optimus.parse(optimus, ~w{--version})
  end

  test "parse: --help" do
    {:ok, optimus} = Optimus.new([])
    assert :help == Optimus.parse(optimus, ~w{--help})
  end

  test "parse: help" do
    {:ok, optimus} = Optimus.new([
      subcommands: [
        sub: [
          name: "sub"
        ]
      ]
    ])
    assert {:help, [:sub]} == Optimus.parse(optimus, ~w{help sub})
  end

  test "parse: invalid help" do
    {:ok, optimus} = Optimus.new([
      subcommands: [
        sub: [
          name: "sub"
        ]
      ]
    ])
    assert {:error, _} = Optimus.parse(optimus, ~w{help subinvalid})
  end


end
