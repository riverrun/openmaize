defmodule <%= base %>.SessionController do
  use <%= base %>.Web, :controller

  import <%= base %>.Authorize<%= if confirm do %>
  alias <%= base %>.{Mailer, User}

  plug Openmaize.ConfirmEmail,
    [mail_function: &Mailer.receipt_confirm/1] when action in [:confirm_email]<% else %>
  alias <%= base %>.User<% end %>

  plug Openmaize.Login when action in [:create]
  #plug Openmaize.Login, [unique_id: :email] when action in [:create]

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(%Plug.Conn{private: %{openmaize_error: message}} = conn, _params) do
    err_go conn, message, session_path(conn, :new)
  end
  def create(%Plug.Conn{private: %{openmaize_user: %{id: id}}} = conn, _params) do
    put_session(conn, :user_id, id)
    |> info_go("You have been logged in", user_path(conn, :index))
  end

  def delete(conn, params) do
    configure_session(conn, drop: true) |> info_go(message, session_path(conn, :new))
  end<%= if confirm do %>

  def confirm_email(%Plug.Conn{private: %{openmaize_error: message}} = conn, _params) do
    err_go conn, message, session_path(conn, :new)
  end
  def confirm_email(%Plug.Conn{private: %{openmaize_info: message}} = conn, _params) do
    info_go conn, message, session_path(conn, :new)
  end<% end %>
end
