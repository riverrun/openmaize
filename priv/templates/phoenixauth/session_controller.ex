defmodule <%= base %>.SessionController do
  use <%= base %>.Web, :controller

<%= if api do %>
  import OpenmaizeJWT.Plug<% else %>
  import <%= base %>.Authorize<% end %><%= if confirm do %>
  alias <%= base %>.Mailer

  plug Openmaize.ConfirmEmail,
    [mail_function: &Mailer.receipt_confirm/1] when action in [:confirm_email]<% end %>

  plug Openmaize.Login when action in [:create]
  #plug Openmaize.Login, [unique_id: :email] when action in [:create]<%= if not api do %>

  def new(conn, _params) do
    render conn, "new.html"
  end<% end %>

  def create(%Plug.Conn{private: %{openmaize_error: message}} = conn, _params) do<%= if api do %>
    render(conn, <%= base %>.ErrorView, "401.json", [])<% else %>
    auth_error conn, message, session_path(conn, :new)<% end %>
  end
  def create(%Plug.Conn{private: %{openmaize_user: %{id: id}}} = conn, _params) do<%= if api do %>
    add_token(conn, user, :username) |> send_resp<% else %>
    put_session(conn, :user_id, id)
    |> auth_info("You have been logged in", user_path(conn, :index))<% end %>
  end

  def delete(conn, _params) do<%= if api do %>
    logout_user(conn)
    |> render(<%= base %>.UserView, "info.json", %{info: message})<% else %>
    configure_session(conn, drop: true)
    |> auth_info("You have been logged out", page_path(conn, :index))<% end %>
  end<%= if confirm do %>

  def confirm_email(%Plug.Conn{private: %{openmaize_error: message}} = conn, _params) do<%= if api do %>
    render(conn, <%= base %>.ErrorView, "error.json", %{error: message})<% else %>
    auth_error conn, message, session_path(conn, :new)<% end %>
  end
  def confirm_email(%Plug.Conn{private: %{openmaize_info: message}} = conn, _params) do<%= if api do %>
    render(conn, <%= base %>.UserView, "info.json", %{info: message})<% else %>
    auth_info conn, message, session_path(conn, :new)<% end %>
  end<% end %>
end
