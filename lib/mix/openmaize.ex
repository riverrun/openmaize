defmodule Mix.Openmaize do

  @doc """
  Copy templates to the main app.
  """
  def copy_files(files, binding) do
    srcdir = Path.join Application.app_dir(:openmaize, "priv"), "templates"
    targetdir = Path.join Application.app_dir(binding[:base])
    for {source, target} <- files do
      contents = Eex.eval_file Path.join(srcdir, source), binding
      Mix.Generator.create_file Path.join(targetdir, target), contents
    end
  end

  @doc """
  Returns the module base name based on the configuration value.
  """
  def base_name do
    app = Mix.Project.config |> Keyword.fetch!(:app)
    Mix.Utils.camelize app
  end

end
