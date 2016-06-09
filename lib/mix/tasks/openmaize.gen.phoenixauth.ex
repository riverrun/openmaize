defmodule Mix.Tasks.Openmaize.Gen.Phoenixauth do
  use Mix.Task

  @moduledoc """
  Create modules for authorization and email confirmation.

  ## Options

  There are two options:

    * api - provide functions for an api
      * the default is false
    * confirm - provide functions for email confirmation and password resetting
      * the default is false

  ## Examples

  In the root directory of your project, run the following command:

      mix openmaize.gen.phoenixauth

  This command will create an Authorize module in the `web/controllers`
  directory and tests in the `test/controllers` directory.

  To add email confirmation functionality, run the following command:

      mix openmaize.gen.phoenixauth --confirm

  In addition to the Authorize module and tests, this command will
  create a Confirm module in the `web/controllers` directory and
  tests in the `tests/controllers` directory.
  """

  @doc false
  def run(args) do
    switches = [api: :boolean, confirm: :boolean]
    {opts, _argv, _} = OptionParser.parse(args, switches: switches)

    mod_name = Mix.Openmaize.base_name
    srcdir = Path.join [Application.app_dir(:openmaize, "priv"), "templates",
                        opts[:api] && "api" || "html"]

    files = [{"authorize.ex", "web/controllers/authorize.ex"},
             {"authorize_test.exs", "test/controllers/authorize_test.exs"}]
    if opts[:confirm] do
      files = files ++ [{"confirm.ex", "web/controllers/confirm.ex"},
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
