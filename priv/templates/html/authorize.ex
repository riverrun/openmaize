defmodule <%= base %>.Authorize do
  import Plug.Conn
  import Phoenix.Controller
  import <%= base %>.Router.Helpers

  @redirects %{"admin" => "/admin", "user" => "/users", nil => "/"}

  def authorize_action(%Plug.Conn{assigns: %{current_user: nil}} = conn, _, _) do
    unauthenticated conn
  end
  def authorize_action(%Plug.Conn{assigns: %{current_user: current_user},
                                  params: params} = conn, roles, module) do
    if current_user.role in roles do
      apply(module, action_name(conn), [conn, params, current_user])
    else
      unauthorized conn, current_user
    end
  end

  def unauthenticated(conn, message \\ "You need to log in to view this page") do
    conn |> put_flash(:error, message) |> redirect(to: login_path(conn, :login)) |> halt
  end

  def unauthorized(conn, current_user, message \\ "You are not authorized to view this page") do
    conn |> put_flash(:error, message) |> redirect(to: @redirects[current_user.role]) |> halt
  end

  def id_check(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts) do
    unauthenticated conn
  end
  def id_check(%Plug.Conn{params: %{"id" => id},
              assigns: %{current_user: %{id: current_id} = current_user}} = conn, _opts) do
    id == to_string(current_id) and conn || unauthorized conn, current_user
  end

  def handle_login(%Plug.Conn{private: %{openmaize_error: message}} = conn, _params) do
    unauthenticated conn, message
  end
  def handle_login(%Plug.Conn{private:
                            %{openmaize_user: %{role: role}}} = conn, _params) do
    conn |> put_flash(:info, "You have been logged in") |> redirect(to: @redirects[role])
  end

  def handle_logout(%Plug.Conn{private: %{openmaize_info: message}} = conn, _params) do
    conn |> put_flash(:info, message) |> redirect(to: "/")
  end
end
