defmodule Mix.Tasks.Openmaize.Gen.Ectodb do
  use Mix.Task

  @moduledoc """
  Create modules for tasks that use Ecto to call the database.

  In most cases, you will not need to call this task directly,
  as it is called by `openmaize.gen.phoenixauth`.
  """

  @doc false
  def run(args) do
    switches = [confirm: :boolean]
    {opts, _argv, _} = OptionParser.parse(args, switches: switches)

    base = Openmaize.Utils.base_module
    srcdir = Path.join [Application.app_dir(:openmaize, "priv"), "templates", "database"]

    files = [{:eex, "openmaize_ecto.ex", "web/models/openmaize_ecto.ex"},
     {:eex, "openmaize_ecto_test.exs", "test/models/openmaize_ecto_test.exs"}]

    Mix.Openmaize.copy_files(srcdir, files, base: base, confirm: opts[:confirm])
    |> instructions
  end

  @doc false
  def instructions(oks) do
    if :ok in oks do
      Mix.shell.info """

      Please check the generated files. Certain details in them, such as
      paths, user details, etc., will most likely need to be changed.

      See the documentation for Openmaize.Config for further details
      on how to configure Openmaize.
      """
    else
      Mix.shell.info """

      No files have been installed.
      """
    end
  end
end
