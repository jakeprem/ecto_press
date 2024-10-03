defmodule EctoPress.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/jakeprem/ecto_press"
  @elixir_version "~> 1.15"

  def project do
    [
      app: :ecto_press,
      version: @version,
      elixir: @elixir_version,
      deps: deps(),
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env()),
      docs: docs(),
      description: "Automate context boilerplate."
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      name: :ecto_press,
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url
      },
      maintainers: ["Jake Prem"]
    ]
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      main: "EctoPress",
      source_url: @source_url,
      homepage_url: @source_url,
      extras: ["README.md"]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:ecto, "~> 3.12"},
      {:inflex, "~> 2.1"}
    ]
  end
end
