defmodule Openmaize.AccessControl do
  @moduledoc """
  Function plugs to handle authorization.

  The functions in this module need to be run after the Openmaize.Authenticate
  plug, as they use the `current_user` value in `conn.assigns`.

  With all of these functions, if the current_user is nil, or if there is
  any other error, the connection will be halted. If the `redirects` option
  is set to true, which is the default, the user will be redirected to the
  login page.
  """

  import Openmaize.Report

  @doc """
  Verify that the user is authorized to access the requested page / resource.

  This check is based on user role.

  This function has two options:

  * roles - a list of permitted roles
  * redirects - if true, which is the default, redirect on login / logout

  ## Examples with Phoenix

  In the relevant `controller.ex` file:

      import Openmaize.AccessControl

  Only allow users with the role "admin" to access the pages in that module:

      plug :authorize, roles: ["admin"]

  Only allow users with the role "admin" to access the create and update pages
  (this means that the other pages are unprotected):

      plug :authorize, [roles: ["admin"]] when action in [:create, :update]

  Allow users with the role "admin" or "user" to access pages, and set redirects to false:

      plug :authorize, roles: ["admin", "user"], redirects: false

  """
  def authorize(%Plug.Conn{assigns: %{current_user: current_user}} = conn, opts) do
    opts = {Keyword.get(opts, :roles, []), Keyword.get(opts, :redirects, true)}
    full_check(conn, opts, current_user)
  end

  @doc """
  Verify that the user, based on the user id, is authorized to access the
  requested page / resource.

  This check only performs a check to see if the user id is correct. You will
  need to use the `authorize` plug to verify the user's role.

  This function has one option:

  * redirects - if true, which is the default, redirect on login / logout
  """
  def authorize_id(%Plug.Conn{params: %{"id" => id},
                              assigns: %{current_user: current_user}} = conn, opts) do
    redirects = Keyword.get(opts, :redirects, true)
    id_check(conn, redirects, id, current_user)
  end

  defp full_check(_conn, {[], _}, _),
    do: raise ArgumentError, "You need to set the `roles` option for :authorize"
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
    handle_error(conn, message, redirects)
  end

  defp nopermit_error(%Plug.Conn{request_path: path} = conn, role, redirects) do
    message = "You do not have permission to view #{path}"
    handle_error(conn, role, message, redirects)
  end
end
