defmodule Openmaize.IdCheck do
  @moduledoc """
  Plug to perform a further check based on the user id.

  This plug needs to be called after Openmaize.Authorize, which makes the
  initial authorization checks.

  For this plug to work, you need to have the start of the path
  and the start of the path + "/:id" in the protected map in the config.
  For example, the following entry protects "/users" and checks ids under
  "/users":

      config: openmaize,
        protected: %{"/users" => ["user"], "/users/:id" => ["user"]}

  There are two options:

  * redirects
      * if true, which is the default, redirect if authorized or if there is an error
  * show
      * if true, the user is allowed to see pages that are not his / her id, but cannot edit them
      * if false, which is the default, the user cannot view these pages

  ## Examples

  Call IdCheck without any options:

      Plug Openmaize.IdCheck

  Call IdCheck without redirects:

      Plug Openmaize.IdCheck, redirects: false

  Call IdCheck and allow users to view the pages of other ids:

      Plug Openmaize.IdCheck, show: true

  """

  alias Openmaize.Authorize
  alias Openmaize.Config

  @behaviour Plug

  def init(opts), do: opts

  @doc """
  Verify that the user, based on id, is authorized to access the page / resource.
  """
  def call(%Plug.Conn{private: private, assigns: assigns} = conn, opts) do
    if Map.get(private, :openmaize_skip) == true do
      conn
    else
      opts = {Keyword.get(opts, :redirects, true), Keyword.get(opts, :show, false)}
      %{path: path, match: match} = Map.take(private.openmaize_vars, [:path, :match])
      if (match <> "/:id") in Map.keys(Config.protected) do
        run(conn, opts, Map.get(assigns, :current_user), path, match)
      else
        conn
      end
    end
  end
  defp run(conn, {redirects, false}, data, path, match) do
    id_noshow(data, path, match) |> Authorize.authorized?(conn, {redirects, false})
  end
  defp run(conn, {redirects, true}, data, path, match) do
    id_noedit(data, path, match) |> Authorize.authorized?(conn, {redirects, false})
  end

  defp id_noedit(data, path, match) do
    if Regex.match?(~r{#{match}/[0-9]+/}, path) do
      check_match(data, path, match, "/")
    else
      :ok
    end
  end

  defp id_noshow(data, path, match) do
    if Regex.match?(~r{#{match}/[0-9]+(/|$)}, path) do
      check_match(data, path, match, "")
    else
      :ok
    end
  end

  defp check_match(%{id: id, role: role}, path, match, suffix) do
    if Kernel.match?({0, _}, :binary.match(path, "#{match}/#{id}#{suffix}")) do
      :ok
    else
      {:error, role, "You do not have permission to view #{path}"}
    end
  end

end
