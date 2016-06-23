defmodule Openmaize.Mixfile do
  use Mix.Project

  @version "1.0.0-beta.0"

  @description """
  Authentication library for Elixir using Plug
  """

  def project do
    [app: :openmaize,
     version: @version,
     elixir: "~> 1.2",
     name: "Openmaize",
     description: @description,
     package: package(),
     source_url: "https://github.com/riverrun/openmaize",
     deps: deps()]
  end

  def application do
    [applications: [:logger, :cowboy, :plug, :comeonin]]
  end

  defp deps do
    [{:cowboy, "~> 1.0"},
     {:plug, "~> 1.1"},
     {:comeonin, "~> 2.5"},
     {:openmaize_jwt, "~> 0.11", optional: true},
     {:ecto, "~> 2.0", optional: true},
     {:postgrex, "~> 0.11", optional: true},
     {:not_qwerty123, "~> 1.2", optional: true},
     {:earmark, "~> 0.2", only: :dev},
     {:ex_doc,  "~> 0.12", only: :dev}]
  end

  defp package do
    [maintainers: ["David Whitlock"],
     licenses: ["BSD"],
     links: %{"GitHub" => "https://github.com/riverrun/openmaize",
      "Docs" => "http://hexdocs.pm/openmaize"}]
  end
end
