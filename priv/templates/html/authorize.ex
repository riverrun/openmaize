defmodule <%= base %>.Authorize do

  import Plug.Conn
  import Phoenix.Controller<%= if roles do %>

  @redirects %{"admin" => "/admin", "user" => "/users", nil => "/"}

  def auth_action_role(%Plug.Conn{assigns: %{current_user: nil}} = conn, _, _) do
    unauthenticated conn
  end
  def auth_action_role(%Plug.Conn{assigns: %{current_user: current_user},
    params: params} = conn, roles, module) do
    if current_user.role in roles do
      apply(module, action_name(conn), [conn, params, current_user])
    else
      unauthorized conn, current_user
    end
  end<% else %>

  def auth_action(%Plug.Conn{assigns: %{current_user: nil}} = conn, _) do
    unauthenticated conn
  end
  def auth_action(%Plug.Conn{assigns: %{current_user: current_user}} = conn, _) do
    apply(module, action_name(conn), [conn, params, current_user])
  end<% end %>

  @doc """
  Handle login using Openmaize.

  If you are using two-factor authentication, uncomment the first commented
  out section - the one that includes 'render conn, "twofa.html", id: id'.

  If you are using 'remember me' functionality, uncomment the second section.
  """
  def handle_login(%Plug.Conn{private: %{openmaize_error: message}} = conn, _params) do
    unauthenticated conn, message
  end
  #def handle_login(%Plug.Conn{private: %{openmaize_otpdata: id}} = conn, _) do
    #render conn, "twofa.html", id: id
  #end
  #def handle_login(%Plug.Conn{private: %{openmaize_user: %{id: id, role: role, remember: true}}} = conn,
   #%{"user" => %{"remember_me" => "true"}}) do
    #conn
    #|> Openmaize.Remember.add_cookie(id)
    #|> put_flash(:info, "You have been logged in")<%= if roles do %>
    #|> redirect(to: @redirects[role])
  #end
  def handle_login(%Plug.Conn{private: %{openmaize_user: %{id: id, role: role}}} = conn, _params) do<% else %>
    #|> redirect(to: "/users")
  #end
  def handle_login(%Plug.Conn{private: %{openmaize_user: %{id: id}}} = conn, _params) do<% end %>
    conn
    |> put_session(:user_id, id)
    |> put_flash(:info, "You have been logged in")<%= if roles do %>
    |> redirect(to: @redirects[role])<% else %>
    |> redirect(to: "/users")<% end %>
  end

  @doc """
  Handle logout using Openmaize.

  If you are using 'remember me' functionality, uncomment the
  'Openmaize.Remember.delete_rem_cookie' line.
  """
  def handle_logout(conn, _params) do
    configure_session(conn, drop: true)
    #|> Openmaize.Remember.delete_rem_cookie
    |> put_flash(:info, "You have been logged out")
    |> redirect(to: "/")
  end

  def unauthenticated(conn, message \\ "You need to log in to view this page") do
    conn
    |> put_flash(:error, message)
    |> redirect(to: "/login")
    |> halt
  end

  def unauthorized(conn, current_user, message \\ "You are not authorized to view this page") do
    conn
    |> put_flash(:error, message)<%= if roles do %>
    |> redirect(to: @redirects[current_user.role])<% else %>
    |> redirect(to: "/users")<% end %>
    |> halt
  end
end
