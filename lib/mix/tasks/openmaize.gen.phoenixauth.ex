defmodule Mix.Tasks.Openmaize.Gen.Phoenixauth do
  use Mix.Task

  @moduledoc """
  Create modules for authorization and, optionally, email confirmation.

  ## Options

  There is one option:

    * api - provide functions for an api, using OpenmaizeJWT and JSON Web Tokens
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

  @auth [{"authorize.ex", "web/controllers/authorize.ex"},
       {"page_controller.ex", "web/controllers/page_controller.ex"},
       {"user_controller.ex", "web/controllers/user_controller.ex"},
       {"authorize_test.exs", "test/controllers/authorize_test.exs"}]

  @confirm [{"confirm.ex", "web/controllers/confirm.ex"},
       {"confirm_test.exs", "test/controllers/confirm_test.exs"}]

  @html [{"login.html.eex", "web/templates/page/login.html.eex"}]

  @doc false
  def run(args) do
    switches = [api: :boolean]
    {opts, _argv, _} = OptionParser.parse(args, switches: switches)

    mod_name = Openmaize.Utils.base_name
    confirm = Mix.shell.yes?("\nAdd email confirmation?")
    srcdir = Path.join [Application.app_dir(:openmaize, "priv"), "templates",
     opts[:api] && "api" || "html"]

    files = if opts[:api], do: @auth, else: @auth ++ @html
    files = if confirm, do: files ++ @confirm, else: files

    Mix.Openmaize.copy_files(srcdir, files, mod_name, confirm)
    |> instructions()
  end

  @doc false
  def instructions(oks) do
    if :ok in oks do # need more info about additions to web/models/user.ex and web/router.ex
      Mix.shell.info """

      Please check the generated files. You might need to uncomment certain
      lines and / or change certain details, such as paths, user details,
      roles, etc.

      Before you use Openmaize, you need to install a module which implements
      the Openmaize.Database behaviour. If you are using Ecto, you can generate a
      template for this by running the following command:

          mix openmaize.gen.ectodb

      You may also need to configure Openmaize. See the documentation for
      Openmaize.Config for details.
      """
    else
      Mix.shell.info """

      No files have been installed.
      """
    end
  end
end
