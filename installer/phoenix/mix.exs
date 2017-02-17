defmodule Openmaize.Phx.Mixfile do
  use Mix.Project

  @version "3.0.0"

  def project do
    [app: :openmaize_phx,
     version: @version,
     aliases: aliases(),
     elixir: "~> 1.4"]
  end

  def application do
    [extra_applications: []]
  end

  defp build_releases(_) do
    Mix.Tasks.Compile.run([])
    Mix.Tasks.Archive.Build.run([])
    Mix.Tasks.Archive.Build.run(["--output=openmaize_phx.ez"])
    File.rename("openmaize_phx.ez", "../archives/openmaize_phx.ez")
    File.rename("openmaize_phx-#{@version}.ez", "../archives/openmaize_phx-#{@version}.ez")
  end

  defp aliases do
    [build: [&build_releases/1]]
  end
end
