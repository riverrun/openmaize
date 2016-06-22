defmodule Mix.Tasks.Openmaize.Gen.Ectodb do
  use Mix.Task

  @moduledoc """
  Create modules for database-related tasks.
  """

  @doc false
  def run(_) do
    mod_name = Mix.Openmaize.base_name
    srcdir = Path.join [Application.app_dir(:openmaize, "priv"), "templates", "database"]

    files = [{"ecto_db.ex", "web/models/ecto_db.ex"},
     {"ecto_db_test.exs", "test/models/ecto_db_test.exs"}]

    Mix.Openmaize.copy_files(srcdir, files, mod_name)
    |> instructions()
  end

  @doc false
  def instructions(oks) do
    if :ok in oks do
      Mix.shell.info """

      Please check the generated files. Certain details in them, such as
      paths, user details, roles, etc., will most likely need to be
      changed.

      You will also need to configure set the `db_module` value in the
      config. See the documentation for Openmaize.Config for details.
      """
    else
      Mix.shell.info """

      No files have been installed.
      """
    end
  end
end
