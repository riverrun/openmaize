defmodule PasswordResetController do
  use <%= base %>.Web, :controller

  def create(conn, opts) do
  end

  def update(%Plug.Conn{private: %{openmaize_error: message}} = conn, _params) do
    render(conn, <%= base %>.ErrorView, "error.json", %{error: message})
  end
  def update(%Plug.Conn{private: %{openmaize_info: message}} = conn, _params) do
    logout_user(conn)
    |> render(<%= base %>.UserView, "info.json", %{info: message})
  end
end
