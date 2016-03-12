defmodule <%= base %>.Auth do
  import Plug.Conn
  import Phoenix.Controller

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

  def unauthenticated(conn) do
    render(conn, <%= base %>.ErrorView, "401.json", [])
  end

  def unauthorized(conn, _current_user) do
    render(conn, <%= base %>.ErrorView, "403.json", [])
  end

  def id_check(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts) do
    unauthenticated conn
  end
  def id_check(%Plug.Conn{params: %{"id" => id},
              assigns: %{current_user: %{id: current_id} = current_user}} = conn, _opts) do
    id == to_string(current_id) and conn || unauthorized conn, current_user
  end

  def handle_login(%Plug.Conn{private: %{openmaize_error: _message}} = conn, _params) do
    unauthenticated conn
  end
  def handle_login(%Plug.Conn{private: %{openmaize_user: _user}} = conn, _params) do
    send_resp conn
  end

  def handle_logout(%Plug.Conn{private: %{openmaize_info: message}} = conn, _params) do
    render(conn, <%= base %>.UserView, "info.json", %{info: message})
  end

  def handle_confirm(%Plug.Conn{private: %{openmaize_error: message}} = conn, _params) do
    render(conn, <%= base %>.ErrorView, "error.json", %{error: message})
  end
  def handle_confirm(%Plug.Conn{private: %{openmaize_info: message}} = conn, _params) do
    render(conn, <%= base %>.UserView, "info.json", %{info: message})
  end

  def handle_reset(%Plug.Conn{private: %{openmaize_error: message}} = conn, _params) do
    render(conn, <%= base %>.ErrorView, "error.json", %{error: message})
  end
  def handle_reset(%Plug.Conn{private: %{openmaize_info: message}} = conn, _params) do
    render(conn, <%= base %>.UserView, "info.json", %{info: message})
  end

end
