defmodule Mix.Tasks.Openmaize.Gen.Phoenixauth do
  use Mix.Task

  @moduledoc """
  Create modules for authorization and, optionally, email confirmation.

  ## Options

  There is one option:

    * api - provide functions for an api
      * the default is false

  ## Examples

  In the root directory of your project, run the following command
  (add the `--api` option if your app is for an api):

      mix openmaize.gen.phoenixauth

  This command will create an Authorize module in the `web/controllers`
  directory and tests in the `test/controllers` directory.

  You will be asked if you want to add modules for email confirmation
  and password resetting, and if you reply yes, there will be a Confirm
  module created in the `web/controllers` directory and tests added to
  the `tests/controllers` directory.
  """

  @doc false
  def run(args) do
    switches = [api: :boolean]
    {opts, _argv, _} = OptionParser.parse(args, switches: switches)

    mod_name = Mix.Openmaize.base_name
    srcdir = Path.join [Application.app_dir(:openmaize, "priv"), "templates",
     opts[:api] && "api" || "html"]

    files = [{"authorize.ex", "web/controllers/authorize.ex"},
     {"authorize_test.exs", "test/controllers/authorize_test.exs"}]
    files = if Mix.shell.yes?("\nAdd modules for email confirmation?") do
      files ++ [{"confirm.ex", "web/controllers/confirm.ex"},
       {"confirm_test.exs", "test/controllers/confirm_test.exs"}]
    end

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

      In the `web/router.ex` file, add the following line to the pipeline:

      plug Openmaize.Authenticate

      You will also need to configure Openmaize. See the documentation for
      Openmaize.Config for details.
      """
    else
      Mix.shell.info """

      No files have been installed.
      """
    end
  end
end
