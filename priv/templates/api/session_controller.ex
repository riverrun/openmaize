defmodule <%= base %>.SessionController do
  use <%= base %>.Web, :controller

  import OpenmaizeJWT.Plug
  import <%= base %>.Authorize<%= if confirm do %>
  alias <%= base %>.Mailer

  plug Openmaize.ConfirmEmail,
    [mail_function: &Mailer.receipt_confirm/1] when action in [:confirm_email]<% end %>

  plug Openmaize.Login when action in [:create]
  #plug Openmaize.Login, [unique_id: :email] when action in [:create]

  def create(%Plug.Conn{private: %{openmaize_error: message}} = conn, _params) do
    render(conn, <%= base %>.ErrorView, "401.json", [])
  end
  def create(%Plug.Conn{private: %{openmaize_user: user}} = conn, _params) do
    add_token(conn, user, :username) |> send_resp
  end

  def delete(conn, _params) do
    logout_user(conn)
    |> render(<%= base %>.UserView, "info.json", %{info: message})
  end<%= if confirm do %>

  def confirm_email(%Plug.Conn{private: %{openmaize_error: message}} = conn, _params) do
    render(conn, <%= base %>.ErrorView, "error.json", %{error: message})
  end
  def confirm_email(%Plug.Conn{private: %{openmaize_info: message}} = conn, _params) do
    render(conn, <%= base %>.UserView, "info.json", %{info: message})
  end<% end %>
end
