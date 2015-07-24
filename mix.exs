defmodule Openmaize.Mixfile do
  use Mix.Project

  @description """
  Authentication and authorization library for Elixir using Plug.
  """

  def project do
    [app: :openmaize,
      version: "0.6.4",
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
      {:plug, "~> 0.13"},
      {:ecto, "~> 0.14"},
      {:comeonin, "~> 1.0"},
      {:joken, "~> 0.15"},
      {:poison, "~> 1.4"},
      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc,  "~> 0.7", only: :dev}
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
