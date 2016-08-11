defmodule <%= base %>.Authorize do
  @moduledoc """
  Module to handle login and logout, and provide examples of user
  authorization, with Openmaize.

  This module provides the `handle_login` and `handle_logout` functions
  to help with logging users in and out. The `handle_login` function
  uses the user's role to redirect the user after logging in. If you are
  not using roles, then you will need to edit this.

  The rest of the documentation for this module will provide examples
  of functions to authorize users that can be added to this module.

  ## Examples of overriding the `action` function

  One way of authorizing users is to customize the `action` function,
  which is run before every route / function in the controller. Below
  are examples of this kind of function. It's important to note that
  all these functions will add another parameter to the functions in
  your controller. For example, `def index(conn, params) do` will become
  `def index(conn, params, user) do`.

  A basic `action` function that just checks if the current_user is set.

  In this file, add:

      def auth_action(%Plug.Conn{assigns: %{current_user: nil}} = conn, _) do
        unauthenticated conn
      end
      def auth_action(%Plug.Conn{assigns: %{current_user: current_user}} = conn, _) do
        apply(module, action_name(conn), [conn, params, current_user])
      end

  In your controller file, import <%= base %>.Authorize and add:

      def action(conn, _), do: auth_action conn, __MODULE__

  A custom `action` function that checks the user id.

  In this file, add:

      def auth_action_id(%Plug.Conn{assigns: %{current_user: nil}} = conn, _) do
        unauthenticated conn
      end
      def auth_action_id(%Plug.Conn{params: %{"user_id" => user_id} = params,
        assigns: %{current_user: current_user}} = conn, module) do
        if user_id == to_string(current_user.id) do
          apply(module, action_name(conn), [conn, params, current_user])
        else
          unauthorized conn, current_user
        end
      end

  In your controller file, import <%= base %>.Authorize and add:

      def action(conn, _), do: auth_action conn, __MODULE__

  A custom `action` function that checks the user role.

  In this file, add:

      def auth_action_role(%Plug.Conn{assigns: %{current_user: nil}} = conn, _, _) do
        unauthenticated conn
      end
      def auth_action_role(%Plug.Conn{assigns: %{current_user: current_user},
        params: params} = conn, roles, module) do
        if current_user.role in roles do
          apply(module, action_name(conn), [conn, params, current_user])
        else
          unauthorized conn, current_user
        end
      end

  In your controller file, import <%= base %>.Authorize and add:

      def action(conn, _), do: auth_action conn, ["admin", "user"], __MODULE__

  ## Example plugs

  These functions can be run before some or all of the functions in the
  controller.

  Plug that checks the user id.

  In this file, add:

      def id_check(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts) do
        unauthenticated conn
      end
      def id_check(%Plug.Conn{params: %{"id" => id}, assigns: %{current_user:
         %{id: current_id} = current_user}} = conn, _opts) do
        id == to_string(current_id) and conn || unauthorized conn, current_user
      end

  In your controller file, import <%= base %>.Authorize and add:

      plug :id_check, when action in [:show, :edit]

  Plug that checks the user role.

  In this file, add:

      def role_check(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts) do
        unauthenticated conn
      end
      def role_check(%Plug.Conn{assigns: %{current_user: current_user}} = conn, opts) do
        roles = Keyword.get(opts, :roles, [])
        current_user.role in roles and conn || unauthorized conn, current_user
      end

  In your controller file, import <%= base %>.Authorize and add:

      plug :role_check ["admin"], when action in [:new, :create, :edit, :update]

  In the example above, only users with the role `admin` can access
  these resources.
  """

  import Plug.Conn
  import Phoenix.Controller

  @redirects %{"admin" => "/admin", "user" => "/users", nil => "/"}

  @doc """
  Handle login using Openmaize.

  If you are using two-factor authentication, uncomment the first commented
  out section - the one that includes `render conn, "twofa.html", id: id`.

  If you are using `remember me` functionality, uncomment the second section.
  """
  def handle_login(%Plug.Conn{private: %{openmaize_error: message}} = conn, _params) do
    unauthenticated conn, message
  end
  #def handle_login(%Plug.Conn{private: %{openmaize_otpdata: id}} = conn, _) do
    #render conn, "twofa.html", id: id
  #end
  #def handle_login(%Plug.Conn{private: %{openmaize_user: %{id: id, role: role, remember: true}}} = conn,
   #%{"user" => %{"remember_me" => "true"}}) do
    #conn
    #|> Openmaize.Remember.add_cookie(id)
    #|> put_flash(:info, "You have been logged in")
    #|> redirect(to: @redirects[role])
  #end
  def handle_login(%Plug.Conn{private: %{openmaize_user: %{id: id, role: role}}} = conn, _params) do
    conn
    |> put_session(:user_id, id)
    |> put_flash(:info, "You have been logged in")
    |> redirect(to: @redirects[role])
  end

  @doc """
  Handle logout using Openmaize.

  If you are using `remember me` functionality, uncomment the
  `Openmaize.Remember.delete_rem_cookie` line.
  """
  def handle_logout(conn, _params) do
    configure_session(conn, drop: true)
    #|> Openmaize.Remember.delete_rem_cookie
    |> put_flash(:info, "You have been logged out")
    |> redirect(to: "/")
  end

  def unauthenticated(conn, message \\ "You need to log in to view this page") do
    conn
    |> put_flash(:error, message)
    |> redirect(to: "/login")
    |> halt
  end

  def unauthorized(conn, current_user, message \\ "You are not authorized to view this page") do
    conn
    |> put_flash(:error, message)
    |> redirect(to: @redirects[current_user.role])
    |> halt
  end
end
