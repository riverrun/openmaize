defmodule Mix.Tasks.Openmaize.Gen.Ectodb do
  use Mix.Task

  @moduledoc """
  Create modules for tasks that use Ecto to call the database.

  In most cases, you will not need to call this task directly,
  as it is called by `openmaize.gen.phoenixauth`.

  ## Options

  There are two options:

    * confirm - add support for email confirmation and resetting passwords
      * the default is false
    * roles - whether to add roles to the authorize functions
      * the default is false
  """

  @doc false
  def run(args) do
    switches = [confirm: :boolean, roles: :boolean]
    {opts, _argv, _} = OptionParser.parse(args, switches: switches)

    base = Openmaize.Utils.base_name
    srcdir = Path.join [Application.app_dir(:openmaize, "priv"), "templates", "database"]

    files = [{"openmaize_ecto.ex", "web/models/openmaize_ecto.ex"},
     {"openmaize_ecto_test.exs", "test/models/openmaize_ecto_test.exs"}]

    edit_user_model("web/models/user.ex", base, opts)
    Mix.Openmaize.copy_files(srcdir, files, base: base)
    |> instructions
  end

  @doc false
  def instructions(oks) do
    if :ok in oks do
      Mix.shell.info """

      Please check the generated files. Certain details in them, such as
      paths, user details, roles, etc., will most likely need to be
      changed.

      See the documentation for Openmaize.Config for further details
      on how to configure Openmaize.
      """
    else
      Mix.shell.info """

      No files have been installed.
      """
    end
  end

  defp edit_user_model(path, base, opts) do
    replace = EEx.eval_string """

  def auth_changeset(model, params, key) do
    model
    |> changeset(params)
    |> <%= base %>.OpenmaizeEcto.add_password_hash(params)<%= if confirm do %>
    |> <%= base %>.OpenmaizeEcto.add_confirm_token(key)
  end

  def reset_changeset(model, params, key) do
    model
    |> cast(params, ~w(email), [])
    |> <%= base %>.OpenmaizeEcto.add_reset_token(key)<% end %>
  end
end
""", base: base, confirm: opts[:confirm]
    File.read(path) |> edit_file(path, opts[:roles], "end\n", replace)
  end

  defp edit_file({:ok, str}, path, roles, match, replace) do
    schema_edit = if roles do
      ":password, :string, virtual: true\n    field :role, :string\n"
    else
      ":password, :string, virtual: true\n"
    end
    newstr = String.replace(str, ":password, :string\n", schema_edit)
              |> String.replace_suffix(match, replace)
    File.write(path, newstr)
  end
  defp edit_file({:error, _}, path, _, _, _) do
    Mix.shell.error "Could not open #{path}"
  end
end
