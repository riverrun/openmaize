defmodule Mix.Openmaize do

  @doc """
  Copy templates to the main app.
  """
  def copy_files(files, app_name, mod_name) do
    srcdir = Path.join Application.app_dir(:openmaize, "priv"), "templates"
    targetdir = Path.join Application.app_dir(app_name)
    for {source, target} <- files do
      contents = Eex.eval_file Path.join(srcdir, source), base: mod_name
      Mix.Generator.create_file Path.join(targetdir, target), contents
    end
  end

  @doc """
  Returns the module base name based on the configuration value.
  """
  def base_name do
    app_name = Mix.Project.config |> Keyword.fetch!(:app)
    {app_name, app_name |> to_string |> Mix.Utils.camelize}
  end

end
