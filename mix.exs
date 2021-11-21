defmodule Optimus.Mixfile do
  use Mix.Project

  @source_url "https://github.com/funbox/optimus"
  @version "0.2.1"

  def project do
    [
      app: :optimus,
      version: @version,
      elixir: "~> 1.3",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      dialyzer: [
        plt_add_deps: true,
        plt_add_apps: [:ssl],
        flags: ["-Werror_handling", "-Wrace_conditions"]
      ],
      package: package()
    ]
  end

  def application do
    [applications: [:logger]]
  end

  cond do
    System.version() |> Version.match?(">= 1.10.0") ->
      def ex_doc_version(), do: "~> 0.23"

    System.version() |> Version.match?(">= 1.7.0") ->
      def ex_doc_version(), do: "~> 0.22.0"

    true ->
      def ex_doc_version(), do: "~> 0.18.0"
  end

  defp deps do
    [
      {:excoveralls, "~> 0.5", only: :test},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:ex_doc, ex_doc_version(), only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      name: :optimus,
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Ilya Averyanov"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      description: "Command line option parser inspired by clap.rs"
    ]
  end

  defp docs do
    [
      extras: [
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Overview"]
      ],
      main: "readme",
      assets: "assets",
      logo: "assets/logo.png",
      source_url: @source_url,
      source_ref: "#{@version}",
      formatters: ["html"]
    ]
  end
end
