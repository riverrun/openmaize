defmodule Mix.Tasks.Openmaize.Gen.Ectodb do
  use Mix.Task

  @moduledoc """
  Create modules for tasks that use Ecto to call the database.
  """

  @doc false
  def run(_) do
    mod_name = Mix.Openmaize.base_name
    srcdir = Path.join [Application.app_dir(:openmaize, "priv"), "templates", "database"]

    files = [{"ecto_db.ex", "web/models/ecto_db.ex"},
     {"ecto_db_test.exs", "test/models/ecto_db_test.exs"}]

    Mix.Openmaize.copy_files(srcdir, files, mod_name)
    |> instructions(mod_name)
  end

  @doc false
  def instructions(oks, mod_name) do
    if :ok in oks do
      Mix.shell.info """

      Please check the generated files. Certain details in them, such as
      paths, user details, roles, etc., will most likely need to be
      changed.

      In the config file, set the `db_module` value:

          config :openmaize,
            db_module: #{mod_name}.EctoDB

      See the documentation for Openmaize.Config and OpenmaizeJWT.Config
      for further details on how to configure Openmaize.
      """
    else
      Mix.shell.info """

      No files have been installed.
      """
    end
  end
end
