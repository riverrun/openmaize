defmodule <%= base %>.SessionController do
  use <%= base %>.Web, :controller<%= if confirm do %>

  alias <%= base %>.Mailer

  plug Openmaize.ConfirmEmail,
    [mail_function: &Mailer.receipt_confirm/1] when action in [:confirm_email]<% end %>
<%= if unique_id == ":username" do %>
  plug Openmaize.Login when action in [:create]
<% else %>
  plug Openmaize.Login, [unique_id: <%= unique_id %>] when action in [:create]
<% end %>
  def create(%Plug.Conn{private: %{openmaize_error: _message}} = conn, _params) do
    put_status(conn, :unauthorized)
    |> render(<%= base %>.AuthView, "401.json", [])
  end
  def create(%Plug.Conn{private: %{openmaize_user: user}} = conn, _params) do
    token = Phoenix.Token.sign(<%= base %>.Endpoint, "user token", user.id)
    render(conn, <%= base %>.SessionView, "info.json", %{info: token})
  end<%= if confirm do %>

  def confirm_email(%Plug.Conn{private: %{openmaize_error: _message}} = conn, _params) do
    put_status(conn, :unauthorized)
    |> render(<%= base %>.AuthView, "401.json", [])
  end
  def confirm_email(%Plug.Conn{private: %{openmaize_info: message}} = conn, _params) do
    render(conn, <%= base %>.SessionView, "info.json", %{info: message})
  end<% end %>
end
