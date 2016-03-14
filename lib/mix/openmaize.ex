defmodule Mix.Openmaize do
  @moduledoc """
  Helper functions for the mix generators.
  """

  @doc """
  Copy templates to the main app.
  """
  def copy_files(srcdir, files, mod_name) do
    for {source, target} <- files do
      contents = EEx.eval_file Path.join(srcdir, source), base: mod_name
      Mix.Generator.create_file target, contents
    end
  end

  @doc """
  Returns the module base name based on the configuration value.
  """
  def base_name do
    Mix.Project.config |> Keyword.fetch!(:app) |> to_string |> Mix.Utils.camelize
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
