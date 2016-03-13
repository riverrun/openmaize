defmodule Mix.Openmaize do

  @doc """
  Copy templates to the main app.
  """
  def copy_files(files, mod_name) do
    srcdir = Path.join Application.app_dir(:openmaize, "priv"), "templates"
    errors = []
    for {source, target} <- files do
      contents = EEx.eval_file Path.join(srcdir, source), base: mod_name
      case Mix.Generator.create_file target, contents do
        :ok -> :ok
        nil -> [target|errors]
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
