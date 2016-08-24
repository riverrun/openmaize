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
