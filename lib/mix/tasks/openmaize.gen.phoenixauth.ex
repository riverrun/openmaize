defmodule Mix.Tasks.Openmaize.Gen.Phoenixauth do
  use Mix.Task

  @moduledoc """
  Create modules for authorization and, optionally, email confirmation.

  ## Options

  There are three options:

    * api - provide functions for an api, using OpenmaizeJWT and JSON Web Tokens
      * the default is false
    * ecto - use ecto for database interaction
      * the default is true
    * roles - whether to add roles to the authorize functions
      * the default is false

  ## Examples

  In the root directory of your project, run the following command
  (add the `--api` option if your app is for an api, add the `--no-ecto`
  option if you are not using ecto, and add the `--roles` option if you
  are using roles):

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

  @doc false
  def run(args) do
    switches = [api: :boolean, ecto: :boolean, roles: :boolean]
    {opts, _argv, _} = OptionParser.parse(args, switches: switches)
    IO.inspect opts

    base = Openmaize.Utils.base_name
    confirm = Mix.shell.yes?("\nDo you want to add email confirmation?")
    srcdir = Path.join [Application.app_dir(:openmaize, "priv"), "templates",
     opts[:api] && "api" || "html"]

    files = if confirm, do: @auth ++ @confirm, else: @auth

    if opts[:ecto], do: Mix.Task.run "openmaize.gen.ectodb", []

    Mix.Openmaize.copy_files(srcdir, files, base: base, confirm: confirm, roles: opts[:roles])
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

          mix openmaize.gen.ectodb # run this directly from this module

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
