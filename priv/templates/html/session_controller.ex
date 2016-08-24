defmodule <%= base %>.SessionController do
  use <%= base %>.Web, :controller

  import <%= base %>.Authorize<%= if confirm do %>
  alias <%= base %>.{Mailer, User}

  plug Openmaize.ConfirmEmail,
    [mail_function: &Mailer.receipt_confirm/1] when action in [:confirm]<% else %>
  alias <%= base %>.User<% end %><%= if roles do %>

  @redirects %{"admin" => "/admin", "user" => "/users", nil => "/"}<% end %>

  plug Openmaize.Login when action in [:create]
  #plug Openmaize.Login, [unique_id: :email] when action in [:create]

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(%Plug.Conn{private: %{openmaize_error: message}} = conn, _params) do
    unauthenticated conn, message
  end
  #def create(%Plug.Conn{private: %{openmaize_otpdata: id}} = conn, _) do
    #render conn, "twofa.html", id: id
  #end
  #def create(%Plug.Conn{private: %{openmaize_user: %{id: id, role: role, remember: true}}} = conn,
   #%{"user" => %{"remember_me" => "true"}}) do
    #conn
    #|> Openmaize.Remember.add_cookie(id)
    #|> put_flash(:info, "You have been logged in")<%= if roles do %>
    #|> redirect(to: @redirects[role])
  #end
  def create(%Plug.Conn{private: %{openmaize_user: %{id: id, role: role}}} = conn, _params) do<% else %>
    #|> redirect(to: "/users")
  #end
  def create(%Plug.Conn{private: %{openmaize_user: %{id: id}}} = conn, _params) do<% end %>
    conn
    |> put_session(:user_id, id)
    |> put_flash(:info, "You have been logged in")<%= if roles do %>
    |> redirect(to: @redirects[role])<% else %>
    |> redirect(to: "/users")<% end %>
  end

  def delete(conn, params) do
    configure_session(conn, drop: true)
    #|> Openmaize.Remember.delete_rem_cookie
    |> put_flash(:info, "You have been logged out")
    |> redirect(to: "/")
  end<%= if confirm do %>

  def confirm_email(%Plug.Conn{private: %{openmaize_error: message}} = conn, _params) do
    unauthenticated conn, message
  end
  def confirm_email(%Plug.Conn{private: %{openmaize_info: message}} = conn, _params) do
    conn |> put_flash(:info, message) |> redirect(to: "/login")
  end<% end %>
end
