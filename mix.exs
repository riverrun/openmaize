defmodule Openmaize.Mixfile do
  use Mix.Project

  @version "2.9.0-dev"

  @description """
  Authentication library for Elixir using Plug
  """

  def project do
    [app: :openmaize,
     version: @version,
     elixir: "~> 1.3",
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
    [{:cowboy, "~> 1.1"},
     {:plug, "~> 1.3"},
     {:comeonin, "~> 3.0"},
     {:ecto, "~> 2.1"},
     {:postgrex, "~> 0.13", optional: true},
     {:not_qwerty123, "~> 1.2", optional: true},
     {:earmark, "~> 1.1", only: :dev},
     {:ex_doc,  "~> 0.14", only: :dev}]
  end

  defp package do
    [maintainers: ["David Whitlock"],
     licenses: ["BSD"],
     links: %{"GitHub" => "https://github.com/riverrun/openmaize",
      "Docs" => "http://hexdocs.pm/openmaize"}]
  end
end
