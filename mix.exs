defmodule Optimus.Mixfile do
  use Mix.Project

  def project do
    [
      app: :optimus,
      version: "0.1.3",
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        "coveralls": :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      dialyzer: [
        plt_add_deps: true,
        plt_add_apps: [:ssl],
        flags: ["-Werror_handling", "-Wrace_conditions"],
      ],
      package: package()
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:dialyxir, "~> 0.4", only: :dev},
      {:excoveralls, "~> 0.5", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp package do
    [
      name: :optimus,
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Ilya Averyanov"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/savonarola/optimus"},
      description: "Command line option parser inspired by clap.rs"
    ]
  end
end
