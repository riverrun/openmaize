defmodule Mix.Tasks.Openmaize.Phx do
  use Mix.Task

  import Mix.Generator

  @moduledoc """
  Create modules for authorization and, optionally, email confirmation.

  ## Options and arguments

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

  @phx_base [{:eex, "test_helpers.ex", "test/support/test_helpers.ex"},
    {:eex, "user_migration.exs", "priv/repo/migrations/timestamp_create_user.exs"},
    {:eex, "user_model.ex", "web/models/user.ex"},
    {:eex, "user_model_test.exs", "test/models/user.exs"}]

  @phx_api [{:eex, "phx_api/session_controller.ex", "web/controllers/session_controller.ex"},
    {:eex, "phx_api/session_controller_test.exs", "test/controllers/session_controller_test.exs"},
    {:eex, "phx_api/session_view.ex", "web/views/session_view.ex"},
    {:eex, "phx_api/user_controller.ex", "web/controllers/user_controller.ex"},
    {:eex, "phx_api/user_controller_test.exs", "test/controllers/user_controller_test.exs"},
    {:eex, "phx_api/user_view.ex", "web/views/user_view.ex"},
    {:eex, "phx_api/router.ex", "web/router.ex"},
    {:eex, "phx_api/auth_view.ex", "web/views/auth_view.ex"},
    {:eex, "phx_api/auth.ex", "web/controllers/auth.ex"},
    {:eex, "phx_api/changeset_view.ex", "web/views/changeset_view.ex"}]

  @phx_html [{:eex, "phx_html/session_controller.ex", "web/controllers/session_controller.ex"},
    {:eex, "phx_html/session_controller_test.exs", "test/controllers/session_controller_test.exs"},
    {:eex, "phx_html/session_view.ex", "web/views/session_view.ex"},
    {:eex, "phx_html/user_controller.ex", "web/controllers/user_controller.ex"},
    {:eex, "phx_html/user_controller_test.exs", "test/controllers/user_controller_test.exs"},
    {:eex, "phx_html/user_view.ex", "web/views/user_view.ex"},
    {:eex, "phx_html/router.ex", "web/router.ex"},
    {:eex, "phx_html/authorize.ex", "web/controllers/authorize.ex"},
    {:text, "phx_html/app.html.eex", "web/templates/layout/app.html.eex"},
    {:text, "phx_html/index.html.eex", "web/templates/page/index.html.eex"},
    {:text, "phx_html/session_new.html.eex", "web/templates/session/new.html.eex"},
    {:text, "phx_html/user_edit.html.eex", "web/templates/user/edit.html.eex"},
    {:text, "phx_html/user_form.html.eex", "web/templates/user/form.html.eex"},
    {:text, "phx_html/user_index.html.eex", "web/templates/user/index.html.eex"},
    {:text, "phx_html/user_new.html.eex", "web/templates/user/new.html.eex"},
    {:text, "phx_html/user_show.html.eex", "web/templates/user/show.html.eex"}]

  @phx_confirm [{:eex, "mailer.ex", "lib/base_name/mailer.ex"}]

  @phx_api_confirm [{:eex, "phx_api/password_reset_controller.ex", "web/controllers/password_reset_controller.ex"},
    {:eex, "phx_api/password_reset_controller_test.exs", "test/controllers/password_reset_controller_test.exs"},
    {:eex, "phx_api/password_reset_view.ex", "web/views/password_reset_view.ex"}]

  @phx_html_confirm [{:eex, "phx_html/password_reset_controller.ex", "web/controllers/password_reset_controller.ex"},
    {:eex, "phx_html/password_reset_controller_test.exs", "test/controllers/password_reset_controller_test.exs"},
    {:eex, "phx_html/password_reset_view.ex", "web/views/password_reset_view.ex"},
    {:text, "phx_html/password_reset_new.html.eex", "web/templates/password_reset/new.html.eex"},
    {:text, "phx_html/password_reset_edit.html.eex", "web/templates/password_reset/edit.html.eex"}]

  root = Path.expand("../templates", __DIR__)
  all_files = @phx_base ++ @phx_api ++ @phx_html ++ @phx_confirm ++ @phx_api_confirm ++ @phx_html_confirm

  for {_, source, _} <- all_files do
    @external_resource Path.join(root, source)
    def render(unquote(source)), do: unquote(File.read!(Path.join(root, source)))
  end

  @doc false
  def run(args) do
    check_directory()
    switches = [confirm: :boolean, api: :boolean]
    {opts, _, _} = OptionParser.parse(args, switches: switches)

    files = @phx_base ++ case {opts[:api], opts[:confirm]} do
      {true, true} -> @phx_api ++ @phx_confirm ++ @phx_api_confirm
      {true, _} -> @phx_api
      {_, true} -> @phx_html ++ @phx_confirm ++ @phx_html_confirm
      _ -> @phx_html
    end

    copy_files(files, base: base_module(), confirm: opts[:confirm], api: opts[:api])

    Mix.shell.info """

    We are almost ready!

    Now edit the `mix.exs` file, adding `:openmaize` to the list of
    `applications` and `{:openmaize, "~> 2.7"},` to the deps.
    Then run `mix deps.get`.

    You will probably need to edit the database username and password
    in the `config` files, and you might need to edit `web/models/user.ex`,
    `priv/repo/migrations/*_create_user.exs` and `web/controllers/session_controller.ex`,
    together with the test files, especially if you are not using `username` to
    identify the user.

    Then, to run the tests:

        mix test

    And to start the server:

        mix phoenix.server

    """
  end

  defp check_directory do
    if Mix.Project.config |> Keyword.fetch(:app) == :error do
      Mix.raise "Not in a Mix project. Please make sure you are in the correct directory."
    end
  end

  defp copy_files(files, opts) do
    for {format, source, target} <- files do
      target = target
               |> String.replace("base_name", base_name())
               |> String.replace("timestamp", timestamp())
      contents = case format do
        :text -> render(source)
        :eex  -> EEx.eval_string(render(source), opts)
      end
      create_file target, contents
    end
  end

  defp base_module do
    base_name() |> Macro.camelize
  end

  defp base_name do
    Mix.Project.config |> Keyword.fetch!(:app) |> to_string
  end

  defp timestamp do
    {{y, m, d}, {hh, mm, ss}} = :calendar.universal_time()
    "#{y}#{pad(m)}#{pad(d)}#{pad(hh)}#{pad(mm)}#{pad(ss)}"
  end

  defp pad(i) when i < 10, do: << ?0, ?0 + i >>
  defp pad(i), do: to_string(i)
end
