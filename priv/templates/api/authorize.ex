defmodule <%= base %>.Authorize do

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
