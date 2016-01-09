defmodule Openmaize.AccessControl do
  @moduledoc """
  Function plugs to handle authorization.

  The functions in this module need to be run after the Openmaize.Authenticate
  plug, as they use the `current_user` value in `conn.assigns`.

  ## Current user and authorization

  The following notes apply to all the functions in this module.

  If the current user's role is in the list of allowed roles, the connection
  will be allowed to proceed.

  If there is a current user, but the role is not in the list of allowed roles,
  the user will be redirected to that user's role's redirect page, or the user
  will be sent a 403 error message, depending on whether the `redirects` option
  is true or false.

  If the current user is nil, the user will be redirected to the login page,
  or just sent a 401 error message.

  ## Customizing the `authorize` and `authorize_id` functions

  These functions can be customized to create new function plugs. In the
  following example, `authorize_id` is customized to allow users with the
  role "admin" to access any page:

      import Openmaize.AccessControl

      def custom_auth(%Plug.Conn{assigns: %{current_user: %{role: "admin"}}} = conn, _opts) do
        conn
      end
      def custom_auth(conn, opts), do: authorize_id(conn, opts)

  This `custom_auth` function can be called just like any other plug:

      plug :custom_auth when action in [:show, :edit, :create]

  """

  import Openmaize.Report

  @doc """
  Verify that the user is authorized to access the requested page / resource.

  This check is based on user role.

  This function has two options:

  * roles - a list of permitted roles
  * redirects - if true, which is the default, redirect if there is an error

  ## Examples with Phoenix

  In the relevant `controller.ex` file, first import this module:

      import Openmaize.AccessControl

  In each of the following examples, the `plug` command needs to be added
  to the top of the file, just below the imports.

  To only allow users with the role "admin" to access the pages in that module:

      plug :authorize, roles: ["admin"]

  To only allow users with the role "admin" to access the create and update pages
  (this means that the other pages are unprotected):

      plug :authorize, [roles: ["admin"]] when action in [:create, :update]

  To allow users with the role "admin" or "user" to access pages, and set
  redirects to false (this example protects every page except the index page):

      plug :authorize, [roles: ["admin", "user"], redirects: false] when not action in [:index]

  To allow users with the role "admin" or "user" to access the index, but
  only allow those users with the role "admin" to access the other pages.

      plug :authorize, [roles: ["admin", "user"]] when action in [:index]
      plug :authorize, [roles: ["admin"]] when not action in [:index]

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

  * redirects - if true, which is the default, redirect if there is an error
  """
  def authorize_id(%Plug.Conn{params: %{"id" => id},
                              assigns: %{current_user: current_user}} = conn, opts) do
    redirects = Keyword.get(opts, :redirects, true)
    id_check(conn, redirects, id, current_user)
  end

  defp full_check(_conn, {[], _}, _) do
    raise ArgumentError, "You need to set the `roles` option for :authorize"
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
    handle_error(conn, message, redirects)
  end

  defp nopermit_error(%Plug.Conn{request_path: path} = conn, role, redirects) do
    message = "You do not have permission to view #{path}"
    handle_error(conn, role, message, redirects)
  end
end
