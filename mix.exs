defmodule Openmaize.Mixfile do
  use Mix.Project

  @version "0.18.1"

  @description """
  Authentication library for Elixir using Plug.
  """

  def project do
    [app: :openmaize,
      version: @version,
      elixir: "~> 1.2",
      name: "Openmaize",
      description: @description,
      package: package,
      source_url: "https://github.com/elixircnx/openmaize",
      deps: deps]
  end

  def application do
    [applications: [:logger, :cowboy, :plug, :comeonin]]
  end

  defp deps do
    [
      {:cowboy, "~> 1.0"},
      {:plug, "~> 1.1"},
      {:comeonin, "~> 2.4"},
      {:openmaize_jwt, "~> 0.9", optional: true},
      {:ecto, "~> 1.1", optional: true},
      {:postgrex, "~> 0.11", optional: true},
      {:not_qwerty123, "~> 1.1", optional: true},
      {:earmark, "~> 0.2", only: :dev},
      {:ex_doc,  "~> 0.11", only: :dev}
    ]
  end

  defp package do
    [
      maintainers: ["David Whitlock"],
      licenses: ["BSD"],
      links: %{"GitHub" => "https://github.com/elixircnx/openmaize",
        "Docs" => "http://hexdocs.pm/openmaize"}
    ]
  end
end
