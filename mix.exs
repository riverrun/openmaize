defmodule Sanction.Mixfile do
  use Mix.Project

  def project do
    [app: :sanction,
     version: "0.0.1",
     elixir: "~> 1.0",
     deps: deps]
  end

  def application do
    [applications: [:logger, :cowboy, :plug]]
  end

  defp deps do
    [
      {:cowboy, "~> 1.0"},
      {:plug, "~> 0.11"},
      {:comeonin, "~> 0.3"},
      {:joken, "~> 0.8"},
      {:poison, "~> 1.3"},
      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc,  "~> 0.7", only: :dev}
    ]
  end
end
