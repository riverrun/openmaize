defmodule Openmaize.Mixfile do
  use Mix.Project

  def project do
    [app: :openmaize,
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
      {:plug, "~> 0.12"},
      {:ecto, "~> 0.11"},
      {:postgrex, "~> 0.8"},
      {:comeonin, "~> 0.8"},
      {:joken, "~> 0.13"},
      {:poison, "~> 1.4"},
      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc,  "~> 0.7", only: :dev}
    ]
  end
end
