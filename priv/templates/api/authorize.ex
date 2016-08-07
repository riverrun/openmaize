defmodule <%= base %>.Authorize do
  @moduledoc """
  Module to handle login and logout, and provide examples of user
  authorization, with OpenmaizeJWT.

  This module provides the `handle_login` and `handle_logout` functions
  to help with logging users in and out.

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
        render(conn, <%= base %>.ErrorView, "401.json", [])
      end
      def auth_action(%Plug.Conn{assigns: %{current_user: current_user}} = conn, _) do
        apply(module, action_name(conn), [conn, params, current_user])
      end

  In your controller file, import <%= base %>.Authorize and add:

      def action(conn, _), do: auth_action conn, __MODULE__

  A custom `action` function that checks the user id.

  In this file, add:

      def auth_action_id(%Plug.Conn{assigns: %{current_user: nil}} = conn, _) do
        render(conn, <%= base %>.ErrorView, "401.json", [])
      end
      def auth_action_id(%Plug.Conn{params: %{"user_id" => user_id} = params,
        assigns: %{current_user: current_user}} = conn, module) do
        if user_id == to_string(current_user.id) do
          apply(module, action_name(conn), [conn, params, current_user])
        else
          render(conn, <%= base %>.ErrorView, "403.json", [])
        end
      end

  In your controller file, import <%= base %>.Authorize and add:

      def action(conn, _), do: auth_action conn, __MODULE__

  A custom `action` function that checks the user role.

  In this file, add:

      def auth_action_role(%Plug.Conn{assigns: %{current_user: nil}} = conn, _, _) do
        render(conn, <%= base %>.ErrorView, "401.json", [])
      end
      def auth_action_role(%Plug.Conn{assigns: %{current_user: current_user},
        params: params} = conn, roles, module) do
        if current_user.role in roles do
          apply(module, action_name(conn), [conn, params, current_user])
        else
          render(conn, <%= base %>.ErrorView, "403.json", [])
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
        render(conn, <%= base %>.ErrorView, "401.json", [])
      end
      def id_check(%Plug.Conn{params: %{"id" => id}, assigns: %{current_user:
         %{id: current_id} = current_user}} = conn, _opts) do
        if id == to_string(current_id), do: conn,
          else: render(conn, <%= base %>.ErrorView, "403.json", [])
      end

  In your controller file, import <%= base %>.Authorize and add:

      plug :id_check, when action in [:show, :edit]

  Plug that checks the user role.

  In this file, add:

      def role_check(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts) do
        render(conn, <%= base %>.ErrorView, "401.json", [])
      end
      def role_check(%Plug.Conn{assigns: %{current_user: current_user}} = conn, opts) do
        roles = Keyword.get(opts, :roles, [])
        if id == to_string(current_id), do: conn,
          else: render(conn, <%= base %>.ErrorView, "403.json", [])
      end

  In your controller file, import <%= base %>.Authorize and add:

      plug :role_check ["admin"], when action in [:new, :create, :edit, :update]

  In the example above, only users with the role `admin` can access
  these resources.
  """

  import OpenmaizeJWT.Plug
  import Plug.Conn
  import Phoenix.Controller

  def handle_login(%Plug.Conn{private: %{openmaize_error: _message}} = conn, _params) do
    render(conn, <%= base %>.ErrorView, "401.json", [])
  end
  def handle_login(%Plug.Conn{private: %{openmaize_user: user}} = conn, _params) do
    add_token(conn, user, :username) |> send_resp
  end

  def handle_logout(%Plug.Conn{private: %{openmaize_info: message}} = conn, _params) do
    logout_user(conn)
    |> render(<%= base %>.UserView, "info.json", %{info: message})
  end
end
