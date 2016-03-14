defmodule Mix.Openmaize do
  @moduledoc """
  Helper functions for the mix generators.
  """

  @doc """
  Copy templates to the main app.
  """
  def copy_files(files, mod_name, confirm) do
    srcdir = Path.join Application.app_dir(:openmaize, "priv"), "templates"
    confirm_path = confirm && Path.join(srcdir, "confirm.ex") || :noconfirm
    for {source, target} <- files do
      contents = gen_contents Path.join(srcdir, source), confirm_path, base: mod_name
      Mix.Generator.create_file target, contents
    end
  end

  @doc """
  Returns the module base name based on the configuration value.
  """
  def base_name do
    Mix.Project.config |> Keyword.fetch!(:app) |> to_string |> Mix.Utils.camelize
  end

  def gen_contents(source, :noconfirm, binding) do
    EEx.eval_file source, binding
  end
  def gen_contents(source, confirm_path, binding) do
    File.read!(source)
    |> String.replace_suffix("end\n", File.read!(confirm_path))
    |> EEx.eval_string(binding)
  end

  def instructions([], mod_name) do
    """
    The module #{mod_name}.Auth has been installed to web/controllers/authorize.ex
    This module contains a custom `authorize_action` and an `id_check` function,
    which can be used for authorization, and it also contains functions for
    handling login, logout, email confirmation and password resetting.
    See the documentation for each function for more details.

    The functions in #{mod_name}.Auth rely on the current_user being
    set by Openmaize.Authenticate. In the `web/router.ex` file, you
    need to add the following line to the pipeline:

        plug Openmaize.Authenticate

    You will also need to configure Openmaize. See the documentation for
    Openmaize.Config for details.
    """
  end
  def instructions(errors, _) do
    files = Enum.join errors, "\n* "
    """
    The following files could not be installed:
    #{files}
   """
  end
end
