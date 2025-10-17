defmodule Optimus.Mixfile do
  use Mix.Project

  @source_url "https://github.com/funbox/optimus"
  @version "0.3.0"

  def project do
    [
      app: :optimus,
      version: @version,
      elixir: "~> 1.18",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      test_coverage: [tool: ExCoveralls],
      dialyzer: [
        plt_add_deps: :apps_direct,
        plt_add_apps: [:ssl],
        flags: ["-Werror_handling", "-Wrace_conditions"]
      ],
      package: package(),
      aliases: aliases()
    ]
  end

  def cli do
    [
      preferred_envs: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:excoveralls, "~> 0.18", only: :test},
      {:dialyxir, "~> 1.4", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
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
      formatters: ["html"],
      api_reference: true
    ]
  end

  defp aliases do
    [
      check: ["format", "credo --strict", "dialyzer"],
      "format.check": ["format --check-formatted"]
    ]
  end
end
