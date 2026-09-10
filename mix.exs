defmodule Metrix.MixProject do
  use Mix.Project

  def project do
    [
      app: :metrix,
      version: "1.0.0",
      description: description(),
      elixir: "~> 1.20",
      deps: deps(),
      package: package(),
      source_url: "https://github.com/rwdaigle/metrix",
      docs: docs()
    ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [extra_applications: [:logger], mod: {Metrix, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:logfmt, "~> 3.3"},
      {:mix_test_watch, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
    Metrix is a library to log custom application metrics, in a well-structured,
    human *and* machine readable format, for use by downstream log processing
    systems (like Librato, Reimann, etc...)
    """
  end

  defp package do
    [
      maintainers: ["Ryan Daigle <ryan.daigle@gmail.com>"],
      contributors: [
        "Jared Knipp <jared@spreedly.com>",
        "Kevin Lewis <kevin@spreedly.com>",
        "Emanuel Evans <mail@emanuel.industries>",
        "Stephen Ball <sdball@gmail.com>",
        "David Santoso"
      ],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/rwdaigle/metrix"},
      files: ~w(mix.exs lib README.md)
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"]
    ]
  end
end
