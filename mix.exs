defmodule Sanction.Mixfile do
  use Mix.Project

  def project do
    [app: :sanction,
     version: "0.0.1",
     elixir: "~> 1.0",
     deps: deps]
  end

  def application do
    [applications: [:logger, :cowboy, :plug, :postgrex, :ecto]]
  end

  defp deps do
    [
      {:cowboy, "~> 1.0"},
      {:plug, "~> 0.11"},
      {:ecto, "~> 0.9.0"},
      {:postgrex, "~> 0.8"},
      {:comeonin, "~> 0.3"},
      {:joken, "~> 0.10"},
      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc,  "~> 0.7", only: :dev}
    ]
  end
end
