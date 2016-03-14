defmodule <%= base %>.Confirm do
  import Plug.Conn
  import Phoenix.Controller
  import <%= base %>.Authorize

  def handle_confirm(%Plug.Conn{private: %{openmaize_error: message}} = conn, _params) do
    unauthenticated conn, message
  end
  def handle_confirm(%Plug.Conn{private: %{openmaize_info: message}} = conn, _params) do
    conn |> put_flash(:info, message) |> redirect(to: login_path(conn, :login))
  end

  def handle_reset(%Plug.Conn{private: %{openmaize_error: message}} = conn,
                  %{"user" => %{"email" => email, "key" => key}}) do
    conn
    |> put_flash(:error, message)
    |> render("reset_form.html", email: email, key: key)
  end
  def handle_reset(%Plug.Conn{private: %{openmaize_info: message}} = conn, _params) do
    conn |> put_flash(:info, message) |> redirect(to: login_path(conn, :login))
  end
end
