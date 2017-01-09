defmodule Mix.Tasks.Openmaize.Phx do
  use Mix.Task

  import Mix.Openmaize.Phx.Generator

  @moduledoc """
  Create modules for authorization and, optionally, email confirmation.

  ## Options and arguments

  There is one argument:

    * unique_id - "username", "email", etc.
      * the default is "username"

  This value will be used in the user file in the models directory,
  the user migrations file and the session controller.

  There are two options:

    * confirm - add functions for email confirmation and password resets
      * the default is false
    * api - create files to authenticate an api instead of a html application
      * the default is false

  ## Examples

  In the root directory of your project, run the following command (add `--confirm`
  if you want to create functions for email confirmation):

      mix openmaize.phx

  If you are using :email to identify (search for) your users, you need
  to add email to the command:

      mix openmaize.phx email

  If you want to create files for an api, run the following command:

      mix openmaize.phx --api

  """

  @doc false
  def run(args) do
    switches = [confirm: :boolean, api: :boolean]
    {opts, argv, _} = OptionParser.parse(args, switches: switches)
    unique_id = case List.first(argv) do
      nil -> ":username"
      uniq -> ":#{uniq}"
    end

    srcdir = Path.expand("../templates", __DIR__)

    files = phx(opts[:api]) ++ case {opts[:api], opts[:confirm]} do
      {true, true} -> phx_api() ++ phx_confirm(true)
      {true, _} -> phx_api()
      {_, true} -> phx_html() ++ phx_confirm(false)
      _ -> phx_html()
    end

    copy_files(srcdir, files, base: base_module(), unique_id: unique_id,
      confirm: opts[:confirm], api: opts[:api])

    Mix.shell.info """

    We are almost ready!

    Now edit the `mix.exs` file, adding `:openmaize` to the list of
    `applications` and `{:openmaize, {"~> 2.7"}},` to the deps.
    Then run `mix deps.get`.

    You might also need to edit the database details in the `config`
    files.

    After that, run `mix test` to run all the tests.

    If you are not using "username" or "email" to index / identify
    the user, and if any of the session_controller tests fail, you
    might need to edit the `test/controllers/session_controller_test.exs`
    and `test/support/test_helpers.ex` files.
    """
  end

  defp phx(api_or_html) do
    dir = if api_or_html, do: "phx_api", else: "phx_html"
    [
      {:eex, "#{dir}/session_controller.ex", "web/controllers/session_controller.ex"},
      {:eex, "#{dir}/session_controller_test.exs", "test/controllers/session_controller_test.exs"},
      {:eex, "#{dir}/session_view.ex", "web/views/session_view.ex"},
      {:eex, "#{dir}/user_controller.ex", "web/controllers/user_controller.ex"},
      {:eex, "#{dir}/user_controller_test.exs", "test/controllers/user_controller_test.exs"},
      {:eex, "#{dir}/user_view.ex", "web/views/user_view.ex"},
      {:eex, "#{dir}/router.ex", "web/router.ex"},
      {:eex, "test_helpers.ex", "test/support/test_helpers.ex"},
      {:eex, "user_migration.exs", "priv/repo/migrations/#{timestamp()}_create_user.exs"},
      {:eex, "user_model.ex", "web/models/user.ex"},
      {:eex, "user_model_test.exs", "test/models/user.exs"}
    ]
  end

  defp phx_api do
    [
      {:eex, "phx_api/auth_view.ex", "web/views/auth_view.ex"},
      {:eex, "phx_api/auth.ex", "web/controllers/auth.ex"},
      {:eex, "phx_api/changeset_view.ex", "web/views/changeset_view.ex"}
    ]
  end

  defp phx_html do
    [
      {:eex, "phx_html/authorize.ex", "web/controllers/authorize.ex"},
      {:text, "phx_html/app.html.eex", "web/templates/layout/app.html.eex"},
      {:text, "phx_html/index.html.eex", "web/templates/page/index.html.eex"},
      {:text, "phx_html/session_new.html.eex", "web/templates/session/new.html.eex"},
      {:text, "phx_html/user_edit.html.eex", "web/templates/user/edit.html.eex"},
      {:text, "phx_html/user_form.html.eex", "web/templates/user/form.html.eex"},
      {:text, "phx_html/user_index.html.eex", "web/templates/user/index.html.eex"},
      {:text, "phx_html/user_new.html.eex", "web/templates/user/new.html.eex"},
      {:text, "phx_html/user_show.html.eex", "web/templates/user/show.html.eex"}
    ]
  end

  defp phx_confirm(api_or_html) do
    {dir, files} = if api_or_html do
      {"phx_api", []}
    else
      {"phx_html",
      [{:text, "phx_html/password_reset_new.html.eex", "web/templates/password_reset/new.html.eex"},
        {:text, "phx_html/password_reset_edit.html.eex", "web/templates/password_reset/edit.html.eex"}]}
    end
    files ++ [
      {:eex, "mailer.ex", "lib/#{base_name()}/mailer.ex"},
      {:eex, "#{dir}/password_reset_controller.ex", "web/controllers/password_reset_controller.ex"},
      {:eex, "#{dir}/password_reset_controller_test.exs", "test/controllers/password_reset_controller_test.exs"},
      {:eex, "#{dir}/password_reset_view.ex", "web/views/password_reset_view.ex"}
    ]
  end
end
