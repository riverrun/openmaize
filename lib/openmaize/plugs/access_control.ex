defmodule Openmaize.AccessControl do
  @moduledoc """
  Function plugs to handle authorization.
  """

  import Openmaize.Report

  @doc """
  Verify that the user is authorized to access the requested page / resource.

  This check is based on user role.
  """
  def authorize(%Plug.Conn{private: %{openmaize_skip: true}} = conn, _opts), do: conn
  def authorize(%Plug.Conn{assigns: assigns} = conn, opts) do
    opts = {Keyword.get(opts, :roles, []), Keyword.get(opts, :redirects, true)}
    full_check(conn, opts, Map.get(assigns, :current_user))
  end

  @doc """
  Verify that the user, based on the user id, is authorized to access the
  requested page / resource.

  This check only performs a check to see if the user id is correct. You will
  need to use the `authorize` plug to verify the user's role.
  """
  def authorize_id(%Plug.Conn{params: %{"id" => id}, assigns: assigns} = conn, opts) do
    redirects = Keyword.get(opts, :redirects, true)
    id_check(conn, redirects, id, Map.get(assigns, :current_user))
  end

  defp full_check(conn, {_, redirects}, nil), do: nouser_error(conn, redirects)
  defp full_check(conn, {roles, redirects}, %{role: role}) do
    if role in roles, do: conn, else: nopermit_error(conn, role, redirects)
  end

  defp id_check(conn, redirects, _id, nil), do: nouser_error(conn, redirects)
  defp id_check(conn, redirects, id, current_user) do
    if id == to_string(current_user.id) do
      conn
    else
      nopermit_error(conn, current_user.role, redirects)
    end
  end

  defp nouser_error(%Plug.Conn{request_path: path} = conn, redirects) do
    message = "You have to be logged in to view #{path}"
    redirects && handle_error(conn, message) || send_error(conn, 401, message)
  end

  defp nopermit_error(%Plug.Conn{request_path: path} = conn, role, redirects) do
    message = "You do not have permission to view #{path}"
    redirects && handle_error(conn, role, message) || send_error(conn, 403, message)
  end

end
