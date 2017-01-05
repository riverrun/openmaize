defmodule <%= base %>.Authorize do

  import Plug.Conn
  import Phoenix.Controller
  import <%= base %>.Router.Helpers

  def auth_action(%Plug.Conn{assigns: %{current_user: nil}} = conn, _) do
    auth_error conn, "You need to log in to view this page", session_path(conn, :new)
  end
  def auth_action(%Plug.Conn{assigns: %{current_user: current_user},
    params: params} = conn, module) do
    apply(module, action_name(conn), [conn, params, current_user])
  end

  def user_check(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts) do
    auth_error conn, "You need to log in to view this page", session_path(conn, :new)
  end
  def user_check(conn, _opts), do: conn

  def id_check(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts) do
    auth_error conn, "You need to log in to view this page", session_path(conn, :new)
  end
  def id_check(%Plug.Conn{params: %{"id" => id}, assigns: %{current_user:
     %{id: current_id}}} = conn, _opts) do
    if id == to_string(current_id), do: conn,
     else: auth_error conn, "You are not authorized to view this page", user_path(conn, :index)
  end

  def auth_info(conn, message, path) do
    conn
    |> put_flash(:info, message)
    |> redirect(to: path)
  end

  def auth_error(conn, message, path) do
    conn
    |> put_flash(:error, message)
    |> redirect(to: path)
    |> halt
  end
end
