defmodule Openmaize.Authorize do
  @moduledoc """
  Plug to verify that users are authorized to access the requested pages
  / resources.

  Authorization is based on user roles, and so you will need a `role` entry
  in your user model.

  This plug can be used as a first stage in authorizing users, and so you
  can call further plugs afterwards to make more fine-grained checks. To
  help these further checks, if authorization is successful, two variables,
  `path` and `match` are stored in the conn.private.openmaize_vars map.
  `path` is the full path of the connection and `match` refers to a matching
  path in the Config.protected map. If no `match` is found, it means that
  the page is unprotected, and extra Openmaize checks are skipped.

  There is one option:

  * redirects
      * if true, which is the default, redirect if authorized or if there is an error

  ## Examples

  Call Authorize without any options:

      Plug Openmaize.Authorize

  Call Authorize without redirects:

      Plug Openmaize.Authorize, redirects: false

  """

  import Plug.Conn
  import Openmaize.Report
  alias Openmaize.Config

  @protected_roles Config.protected
  @protected Map.keys(Config.protected)

  @behaviour Plug

  def init(opts), do: opts

  @doc """
  Verify that the user is authorized to access the requested page / resource.
  """
  def call(%{private: private, assigns: assigns} = conn, opts) do
    if Map.get(private, :openmaize_skip) == true do
      conn
    else
      opts = {Keyword.get(opts, :redirects, true)}
      run(conn, opts, Map.get(assigns, :current_user))
    end
  end
  defp run(conn, opts, data) do
    get_match(conn) |> is_permitted(data) |> finish(conn, opts)
  end

  defp is_permitted({{0, _}, path}, nil) do
    {:error, "You have to be logged in to view #{path}"}
  end
  defp is_permitted(_, nil), do: {:ok, :nomatch}
  defp is_permitted({{0, match_len}, path}, %{role: role}) do
    match = :binary.part(path, {0, match_len})
    if role in Map.get(@protected_roles, match) do
      {:ok, path, match}
    else
      {:error, role, "You do not have permission to view #{path}"}
    end
  end
  defp is_permitted(_, _), do: {:ok, :nomatch}

  defp get_match(conn) do
    path = full_path(conn)
    {:binary.match(path, @protected), path}
  end

  def finish(:ok, conn, _), do: conn
  def finish({:ok, :nomatch}, conn, _), do: put_private(conn, :openmaize_skip, true)
  def finish({:ok, path, match}, conn, _) do
    put_private(conn, :openmaize_vars, %{path: path, match: match})
  end
  def finish({:error, message}, conn, {false, _}), do: send_error(conn, 401, message)
  def finish({:error, message}, conn, _), do: handle_error(conn, message)
  def finish({:error, _, message}, conn, {false, _}), do: send_error(conn, 403, message)
  def finish({:error, role, message}, conn, _), do: handle_error(conn, role, message)

end
