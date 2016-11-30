defmodule Optimus.FormatableHelpTest do
  use ExUnit.Case

  def optimus do
    {:ok, optimus} = Optimus.new(
      name: "awesome",
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
    )
    optimus
  end

  test "arg column help" do
    help = Optimus.FormatableHelp.formatable_help("ARGS:", optimus.args, 80)

    assert help == [
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
      "                  you please, please help me?                                   "
    ]
  end

  test "arg simple help" do
    help = Optimus.FormatableHelp.formatable_help("ARGS:", optimus.args, 10)
    assert help == [
      "ARGS:",
      "",
      "FIRST: Help Help me if you can, I'm feeling down And I do appreciate you being 'round Help me get my feet back on the ground Won't you please, please help me?",
      "SECOND: Help Help me if you can, I'm feeling down And I do appreciate you being 'round Help me get my feet back on the ground Won't you please, please help me?",
      "THIRD: Help Help me if you can, I'm feeling down And I do appreciate you being 'round Help me get my feet back on the ground Won't you please, please help me?"
    ]
  end


  test "options column help" do
    help = Optimus.FormatableHelp.formatable_help("OPTIONS:", optimus.options, 80)

    assert help == [
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
    ]
  end

  test "options simple help" do
    help = Optimus.FormatableHelp.formatable_help("OPTIONS:", optimus.options, 10)

    assert help == [
      "OPTIONS:",
      "",
      "-o: Help Help me if you can, I'm feeling down And I do appreciate you being 'round Help me get my feet back on the ground Won't you please, please help me?",
      "-t, --second-option: Help Help me if you can, I'm feeling down And I do appreciate you being 'round Help me get my feet back on the ground Won't you please, please help me?"
    ]
  end


  test "flag column help" do
    help = Optimus.FormatableHelp.formatable_help("FLAGS:", optimus.flags, 80)

    assert help == [
      "FLAGS:",
      "",
      "    -f, --first-flag        Help Help me if you can, I'm feeling down And I do  ",
      "                            appreciate you being 'round Help me get my feet back",
      "                            on the ground Won't you please, please help me?     ",
      "    -s                      Help Help me if you can, I'm feeling down And I do  ",
      "                            appreciate you being 'round Help me get my feet back",
      "                            on the ground Won't you please, please help me?     ",
    ]
  end

  test "flag simple help" do
    help = Optimus.FormatableHelp.formatable_help("FLAGS:", optimus.flags, 10)

    assert help == [
      "FLAGS:",
      "",
      "-f, --first-flag: Help Help me if you can, I'm feeling down And I do appreciate you being 'round Help me get my feet back on the ground Won't you please, please help me?",
      "-s: Help Help me if you can, I'm feeling down And I do appreciate you being 'round Help me get my feet back on the ground Won't you please, please help me?"
    ]
  end


end
