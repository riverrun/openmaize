defmodule Mix.Tasks.Openmaize.Gen.Ectodb do
  use Mix.Task

  @moduledoc """
  Create modules for tasks that use Ecto to call the database.
  """

  @doc false
  def run(_) do
    base = Openmaize.Utils.base_name
    srcdir = Path.join [Application.app_dir(:openmaize, "priv"), "templates", "database"]

    files = [{"openmaize_ecto.ex", "web/models/openmaize_ecto.ex"},
     {"openmaize_ecto_test.exs", "test/models/openmaize_ecto_test.exs"}]

    edit_user_model("web/models/user.ex", base)
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

  def edit_user_model(path, base) do
    replace = EEx.eval_string """
  def auth_changeset(model, params, key) do
    model
    |> changeset(params)
    |> <%= base %>.OpenmaizeEcto.add_password_hash(params)
    |> <%= base %>.OpenmaizeEcto.add_confirm_token(key)
  end

  def reset_changeset(model, params, key) do
    model
    |> cast(params, ~w(email), [])
    |> <%= base %>.OpenmaizeEcto.add_reset_token(key)
  end
end
""", base: base
    File.read(path) |> edit_file(path, "\nend\n", replace)
  end

  defp edit_file({:ok, str}, path, match, replace) do
    newstr = String.replace(str, ":password, :string", ":password, :string, virtual: true")
              |> String.replace_suffix(match, replace)
    File.write(path, newstr)
  end
  defp edit_file({:error, _}, path, _, _) do
    Mix.shell.info "Could not open #{path}"
  end
end
