defmodule Mix.Tasks.Openmaize.Gen.Phoenixauth do
  use Mix.Task

  @moduledoc """
  Create modules for authorization and, optionally, email confirmation.

  Warning - the following files are overwritten: web/controllers/page_controller.ex,
  web/controllers/user_controller.ex, web/router.ex and web/models/user.ex.
  You will be given the option not to overwrite when you run the command.

  ## Options

  There are three options:

    * unique_id - the name you use to identify the user in the database
      * the default is :username
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
  """

  @auth [{"authorize.ex", "web/controllers/authorize.ex"},
   {"user_controller.ex", "web/controllers/user_controller.ex"},
   {"router.ex", "web/router.ex"}]

  @html [{"session_controller.ex", "web/controllers/session_controller.ex"},
   {"session_controller_test.exs", "test/controllers/session_controller_test.exs"},
   {"session_view.ex", "web/views/session_view.ex"},
   {"new.html.eex", "web/templates/session/new.html.eex"}]

  @doc false
  def run(args) do
    switches = [unique_id: :string, api: :boolean, ecto: :boolean, roles: :boolean]
    {opts, _argv, _} = OptionParser.parse(args, switches: switches)

    base = Openmaize.Utils.base_name
    confirm = Mix.shell.yes?("\nDo you want to add support for email confirmation?")
    srcdir = Path.join [Application.app_dir(:openmaize, "priv"), "templates",
     opts[:api] && "api" || "html"]

    files = if opts[:api], do: @auth, else: @auth ++ @html

    ectodb_opts = if confirm, do: ["--confirm"|args], else: ["--no-confirm"|args]
    if opts[:ecto] != false, do: Mix.Task.run "openmaize.gen.ectodb", ectodb_opts

    Mix.Openmaize.copy_files(srcdir, files, base: base, confirm: confirm,
     roles: opts[:roles], unique_id: get_unique_id(opts[:unique_id]))
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

  defp get_unique_id(unique_id) when is_atom(unique_id), do: unique_id
  defp get_unique_id(unique_id) when is_binary(unique_id), do: String.to_atom unique_id
  defp get_unique_id(_), do: :username
end
