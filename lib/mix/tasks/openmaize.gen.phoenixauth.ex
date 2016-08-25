defmodule Mix.Tasks.Openmaize.Gen.Phoenixauth do
  use Mix.Task

  @moduledoc """
  Create modules for authorization and, optionally, email confirmation.

  Warning - the following files are overwritten: web/controllers/page_controller.ex,
  web/controllers/user_controller.ex, web/router.ex and web/models/user.ex.
  You will be given the option not to overwrite when you run the command.

  ## Options

  There are three options:

    * confirm - add functions for email confirmation and password resets
      * the default is false
    * api - provide functions for an api, using OpenmaizeJWT and JSON Web Tokens
      * the default is false
    * ecto - use ecto for database interaction
      * the default is true

  ## Examples

  Run this command after running `mix phoenix.gen.html` or
  `mix phoenix.gen.json`.

  In the root directory of your project, run the following command
  (add the `--api` option if your app is for an api and / or the `--no-ecto`
  option if you are not using ecto):

      mix openmaize.gen.phoenixauth

  This command will create an Authorize module in the `web/controllers`
  directory and tests in the `test/controllers` directory.
  """

  @auth [{"authorize.ex", "web/controllers/authorize.ex"},
   {"user_controller.ex", "web/controllers/user_controller.ex"},
   {"router.ex", "web/router.ex"}]

  @html [{"session_controller.ex", "web/controllers/session_controller.ex"},
   {"session_controller_test.exs", "test/controllers/session_controller_test.exs"},
   {"session_view.ex", "web/views/session_view.ex"},
   {"session_new.html.eex", "web/templates/session/new.html.eex"}]

  @confirm [{"password_reset_controller.ex", "web/controllers/password_reset_controller.ex"},
   {"password_reset_controller_test.exs", "test/controllers/password_reset_controller_test.exs"},
   {"password_reset_view.ex", "web/views/password_reset_view.ex"},
   {"password_reset_new.html.eex", "web/templates/password_reset/new.html.eex"},
   {"password_reset_edit.html.eex", "web/templates/password_reset/edit.html.eex"}]

  @doc false
  def run(args) do
    switches = [confirm: :boolean, api: :boolean, ecto: :boolean]
    {opts, _argv, _} = OptionParser.parse(args, switches: switches)

    base = Openmaize.Utils.base_name
    srcdir = Path.join [Application.app_dir(:openmaize, "priv"), "templates",
     opts[:api] && "api" || "html"]

    files = if opts[:confirm], do: @auth ++ @confirm, else: @auth
    files = if opts[:api], do: files, else: files ++ @html

    if opts[:ecto] != false, do: Mix.Task.run "openmaize.gen.ectodb", []

    Mix.Openmaize.copy_files(srcdir, files, base: base, confirm: opts[:confirm])
    |> instructions()
  end

  @doc false
  def instructions(oks) do
    if :ok in oks do
      Mix.shell.info """

      Please check the generated files. You might need to uncomment certain
      lines and / or change certain details, such as paths, user details.

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
