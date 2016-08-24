defmodule Mix.Tasks.Openmaize.Gen.Phoenixauth do
  use Mix.Task

  @moduledoc """
  Create modules for authorization and, optionally, email confirmation.

  Warning - the following files are overwritten: web/controllers/page_controller.ex,
  web/controllers/user_controller.ex, web/router.ex and web/models/user.ex.
  You will be given the option not to overwrite when you run the command.

  ## Options

  There are three options:

    * api - provide functions for an api, using OpenmaizeJWT and JSON Web Tokens
      * the default is false
    * ecto - use ecto for database interaction
      * the default is true
    * roles - whether to add roles to the authorize functions
      * the default is false

  ## Examples

  Run this command after running `mix phoenix.gen.html` or
  `mix phoenix.gen.json`.

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
       {"authorize_test.exs", "test/controllers/authorize_test.exs"},
       {"user_controller.ex", "web/controllers/user_controller.ex"},
       {"router.ex", "web/router.ex"}]

  @confirm [{"confirm.ex", "web/controllers/confirm.ex"},
       {"confirm_test.exs", "test/controllers/confirm_test.exs"}]

  @html [{"page_controller.ex", "web/controllers/page_controller.ex"}]

  @doc false
  def run(args) do
    switches = [api: :boolean, ecto: :boolean, roles: :boolean]
    {opts, _argv, _} = OptionParser.parse(args, switches: switches)

    base = Openmaize.Utils.base_name
    confirm = Mix.shell.yes?("\nDo you want to add support for email confirmation and resetting passwords?")
    srcdir = Path.join [Application.app_dir(:openmaize, "priv"), "templates",
     opts[:api] && "api" || "html"]

    files = if confirm, do: @auth ++ @confirm, else: @auth
    files = if opts[:api], do: files, else: files ++ @html

    ectodb_opts = if confirm, do: ["--confirm"|args], else: ["--no-confirm"|args]
    if opts[:ecto] != false, do: Mix.Task.run "openmaize.gen.ectodb", ectodb_opts

    Mix.Openmaize.copy_files(srcdir, files, base: base, confirm: confirm, roles: opts[:roles])
    |> instructions()
  end

  @doc false
  def instructions(oks) do
    if :ok in oks do
      Mix.shell.info """

      Please check the generated files. You might need to uncomment certain
      lines and / or change certain details, such as paths, user details,
      roles, etc.

      Before you use Openmaize, you need to configure Openmaize.
      See the documentation for Openmaize.Config for details.
      """
    else
      Mix.shell.info """

      No files have been installed.
      """
    end
  end
end
