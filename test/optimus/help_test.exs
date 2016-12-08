defmodule Optimus.HelpTest do
  use ExUnit.Case

  def optimus do
    {:ok, optimus} = Optimus.new(
      name: "awesome",
      description: "Elixir App",
      version: "1.0.1",
      author: "Averyanov Ilya av@fun-box.ru",
      about: "Does awesome things",
      args: [
        first: [
          value_name: "FIRST",
          help: "Help Help me if you can, I'm feeling down And I do appreciate you being 'round Help me get my feet back on the ground Won't you please, please help me?"
        ],
        second: [
          value_name: "SECOND",
          help: "Help Help me if you can, I'm feeling down And I do appreciate you being 'round Help me get my feet back on the ground Won't you please, please help me?"
        ],
        third: [
          value_name: "THIRD",
          help: "Help Help me if you can, I'm feeling down And I do appreciate you being 'round Help me get my feet back on the ground Won't you please, please help me?"
        ]
      ],
      flags: [
        first: [
          short: "f",
          long: "first-flag",
          help: "Help Help me if you can, I'm feeling down And I do appreciate you being 'round Help me get my feet back on the ground Won't you please, please help me?"
        ],
        second: [
          short: "s",
          help: "Help Help me if you can, I'm feeling down And I do appreciate you being 'round Help me get my feet back on the ground Won't you please, please help me?"
        ]
      ],
      options: [
        first: [
          value_name: "FIRST_OPTION",
          short: "o",
          help: "Help Help me if you can, I'm feeling down And I do appreciate you being 'round Help me get my feet back on the ground Won't you please, please help me?"
        ],
        second: [
          value_name: "SECOND_OPTION",
          short: "t",
          long: "second-option",
          help: "Help Help me if you can, I'm feeling down And I do appreciate you being 'round Help me get my feet back on the ground Won't you please, please help me?"
        ],
      ],
      subcommands: [
        subcommand: [
          name: "subcommand",
          description: "Elixir App",
          about: "Help Help me if you can, I'm feeling down And I do appreciate you being 'round Help me get my feet back on the ground Won't you please, please help me?",
          allow_unknown_args: false,
          parse_double_dash: false,
          args: [first: []],
          flags: [first: [short: "-f"]],
          options: [first: [short: "-o", parser: :integer]]
        ]
      ]
    )
    optimus
  end

  test "full help" do
    assert [
      "Elixir App 1.0.1",
      "Averyanov Ilya av@fun-box.ru",
      "Does awesome things",
      "",
      "USAGE:",
      "    awesome [--first-flag] [-s] [-o FIRST_OPTION] [--second-option SECOND_OPTION] FIRST SECOND THIRD",
      "    awesome --version",
      "    awesome --help",
      "    awesome help subcommand",
      "",
      "ARGS:",
      "",
      "    FIRST         Help Help me if you can, I'm feeling down And I do appreciate ",
      "                  you being 'round Help me get my feet back on the ground Won't ",
      "                  you please, please help me?                                   ",
      "    SECOND        Help Help me if you can, I'm feeling down And I do appreciate ",
      "                  you being 'round Help me get my feet back on the ground Won't ",
      "                  you please, please help me?                                   ",
      "    THIRD         Help Help me if you can, I'm feeling down And I do appreciate ",
      "                  you being 'round Help me get my feet back on the ground Won't ",
      "                  you please, please help me?                                   ",
      "",
      "FLAGS:",
      "",
      "    -f, --first-flag        Help Help me if you can, I'm feeling down And I do  ",
      "                            appreciate you being 'round Help me get my feet back",
      "                            on the ground Won't you please, please help me?     ",
      "    -s                      Help Help me if you can, I'm feeling down And I do  ",
      "                            appreciate you being 'round Help me get my feet back",
      "                            on the ground Won't you please, please help me?     ",
      "",
      "OPTIONS:",
      "",
      "    -o                         Help Help me if you can, I'm feeling down And I  ",
      "                               do appreciate you being 'round Help me get my    ",
      "                               feet back on the ground Won't you please, please ",
      "                               help me?                                         ",
      "    -t, --second-option        Help Help me if you can, I'm feeling down And I  ",
      "                               do appreciate you being 'round Help me get my    ",
      "                               feet back on the ground Won't you please, please ",
      "                               help me?                                         ",
      "",
      "SUBCOMMANDS:",
      "",
      "    subcommand        Help Help me if you can, I'm feeling down And I do        ",
      "                      appreciate you being 'round Help me get my feet back on   ",
      "                      the ground Won't you please, please help me?              ",
      "" ] == Optimus.Help.help(optimus, [], 80)
  end
end
