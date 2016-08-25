defmodule <%= base %>.Authorize do

  import Plug.Conn
  import Phoenix.Controller
  import <%= base %>.Router.Helpers

  def auth_action(%Plug.Conn{assigns: %{current_user: nil}} = conn, _) do
    err_go conn, "You need to log in to view this page", session_path(conn, :new)
  end
  def auth_action(%Plug.Conn{assigns: %{current_user: current_user},
    params: params} = conn, module) do
    apply(module, action_name(conn), [conn, params, current_user])
  end

  def info_go(conn, message, path) do
    conn
    |> put_flash(:info, message)
    |> redirect(to: path)
  end

  def err_go(conn, message, path) do
    conn
    |> put_flash(:error, message)
    |> redirect(to: path)
    |> halt
  end
end
