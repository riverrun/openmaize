defmodule Openmaize.AccessControl do
  @moduledoc """
  Function plugs to authorize a user's access to a certain page / resource.
  """

  import Plug.Conn

  @doc """
  Verify that the user is authorized to access the requested page / resource.

  This check is based on user role.

  This function has one option:

  * roles - a list of permitted roles

  ## Examples with Phoenix

  In each of the following examples, the `plug` command needs to be added
  to the relevant controller file after importing Openmaize.AccessControl.

  To only allow users with the role "admin" to access the pages in that module:

      plug :authorize, roles: ["admin"]

  To only allow users with the role "admin" to access the create and update pages
  (this means that the other pages are unprotected):

      plug :authorize, [roles: ["admin"]] when action in [:create, :update]

  To allow users with the role "admin" or "user" to access the index, but
  only allow those users with the role "admin" to access the other pages.

      plug :authorize, [roles: ["admin", "user"]] when action in [:index]
      plug :authorize, [roles: ["admin"]] when not action in [:index]

  """
  def authorize(%Plug.Conn{assigns: %{current_user: current_user}} = conn, opts) do
    full_check(conn, Keyword.get(opts, :roles, []), current_user)
  end

  @doc """
  Verify that the user, based on the user id, is authorized to access the
  requested page / resource.

  This check only performs a check to see if the user id is correct. You will
  need to use the `Openmaize.Authorize` plug to verify the user's role.

  ## Examples with Phoenix

  In each of the following examples, the `plug` command needs to be added
  to the relevant controller file after importing Openmaize.AccessControl.

  To not allow other users to view or edit the user's page:

      plug :authorize_id, when action in [:show, :edit]

  """
  def authorize_id(%Plug.Conn{params: %{"id" => id},
                      assigns: %{current_user: current_user}} = conn, _opts) do
    id_check(conn, id, current_user)
  end

  defp full_check(_conn, [], _) do
    raise ArgumentError, "You need to set the `roles` option for :authorize"
  end
  defp full_check(conn, _, nil), do: nouser_error(conn)
  defp full_check(conn, roles, %{role: role}) do
    if role in roles, do: conn, else: nopermit_error(conn, role)
  end

  defp id_check(conn, _id, nil), do: nouser_error(conn)
  defp id_check(conn, id, current_user) do
    if id == to_string(current_user.id) do
      conn
    else
      nopermit_error(conn, current_user.role)
    end
  end

  defp nouser_error(%Plug.Conn{request_path: path} = conn) do
    put_private(conn, :openmaize_error, "You have to be logged in to view #{path}")
  end

  defp nopermit_error(%Plug.Conn{request_path: path} = conn, _role) do
    put_private(conn, :openmaize_error, "You do not have permission to view #{path}")
  end
end
