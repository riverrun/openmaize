defmodule Mix.Openmaize do
  @moduledoc """
  Helper functions for the mix generators.
  """

  @doc """
  Copy templates to the main app.
  """
  def copy_files(srcdir, files, mod_name) do
    errors = []
    for {source, target} <- files do
      contents = EEx.eval_file Path.join(srcdir, source), base: mod_name
      case Mix.Generator.create_file target, contents do
        :ok -> :ok
        false -> [target | errors]
      end
    end
    errors
  end

  @doc """
  Returns the module base name based on the configuration value.
  """
  def base_name do
    Mix.Project.config |> Keyword.fetch!(:app) |> to_string |> Mix.Utils.camelize
  end
end
