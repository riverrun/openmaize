defmodule Openmaize.Mixfile do
  use Mix.Project

  @description """
  Authentication and authorization library for Elixir using Plug.
  """

  def project do
    [app: :openmaize,
      version: "0.7.4",
      elixir: "~> 1.0",
      name: "Openmaize",
      description: @description,
      package: package,
      source_url: "https://github.com/elixircnx/openmaize",
      deps: deps]
  end

  def application do
    [applications: [:logger, :cowboy, :plug, :ecto]]
  end

  defp deps do
    [
      {:cowboy, "~> 1.0"},
      {:plug, "~> 1.0"},
      {:ecto, "~> 1.0"},
      {:comeonin, "~> 1.1"},
      {:joken, "~> 0.15"},
      {:poison, "~> 1.5"},
      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc,  "~> 0.9", only: :dev}
    ]
  end

  defp package do
    [
      contributors: ["David Whitlock"],
      licenses: ["BSD"],
      links: %{"GitHub" => "https://github.com/elixircnx/openmaize",
        "Docs" => "http://hexdocs.pm/openmaize"}
    ]
  end
end
