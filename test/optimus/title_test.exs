defmodule Optimus.TitleTest do
  use ExUnit.Case

  alias Optimus.Title

  test "main command title: full" do
    {:ok, optimus} = Optimus.new(
      description: "Elixir App",
      version: "1.0.1",
      author: "Averyanov Ilya av@fun-box.ru",
      about: "Does awesome things"
    )

    assert ["Elixir App 1.0.1", "Averyanov Ilya av@fun-box.ru", "Does awesome things"] == Title.title(optimus)
  end

  test "main command title: with empty fields" do
    {:ok, optimus} = Optimus.new(
      description: "Elixir App",
    )

    assert ["Elixir App"] == Title.title(optimus)
  end

  test "subcommand title: full" do
    {:ok, optimus} = Optimus.new(
      description: "Elixir App",
      version: "1.0.1",
      author: "Averyanov Ilya av@fun-box.ru",
      about: "Does awesome things",
      subcommands: [
        subcommand: [
          name: "sub",
          description: "Elixir SubApp",
          version: "1.1.1",
          author: "Sub Author",
          about: "Does subawesome things"
        ]
      ]
    )

    assert ["Elixir SubApp 1.1.1", "Sub Author", "Does subawesome things"] == Title.title(optimus, [:subcommand])
  end

  test "subcommand title: with empty fields" do
    {:ok, optimus} = Optimus.new(
      description: "Elixir App",
      version: "1.0.1",
      author: "Averyanov Ilya av@fun-box.ru",
      about: "Does awesome things",
      subcommands: [
        subcommand: [
          name: "sub"
        ]
      ]
    )

    assert ["Elixir App 1.0.1", "Averyanov Ilya av@fun-box.ru", "Does awesome things"] == Title.title(optimus, [:subcommand])
  end


end
