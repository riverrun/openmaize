defmodule Openmaize.Report do
  @moduledoc """
  This module provides error and info messages and handles redirects if
  the option `redirects` is set to true.

  If you are using Phoenix, then the error and info messages will be
  sent to `phoenix_flash` to be shown in the web browser.
  """

  import Plug.Conn
  alias Openmaize.Config

  @doc """
  Handle authentication errors.

  These errors relate to there being no current user for a protected page.

  If redirects is set to true, the user will be redirected to the login
  page. If redirects is false, a json-encoded message will be sent to the
  user.
  """
  def handle_error(conn, message, true) do
    redirect_to_login(conn, %{"error" => message})
  end
  def handle_error(conn, message, false) do
    send_resp(conn, 401, Poison.encode!(%{"error" => message})) |> terminate
  end

  @doc """
  Handle authorization errors.

  These errors relate to the current user not being permitted to access the
  requested page.

  If redirects is set to true, the user will be redirected to the login
  page. If redirects is false, a json-encoded message will be sent to the
  user.
  """
  def handle_error(conn, role, message, true) do
    redirect_to(conn, "#{Config.redirect_pages[role]}", %{"error" => message})
  end
  def handle_error(conn, role, message, false) do
    send_resp(conn, 403, Poison.encode!(%{"error" => message})) |> terminate
  end

  @doc """
  Redirect the connection to the home page with an info message.
  """
  def handle_info(conn, message), do: redirect_to(conn, "/", %{"info" => message})

  @doc """
  Redirect the connection to the user's role's page with an info message.
  """
  def handle_info(conn, role, message) do
    redirect_to(conn, "#{Config.redirect_pages[role]}", %{"info" => message})
  end

  @doc """
  Return and halt the connection. Also, set the openmaize_skip value to true,
  which means that subsequent Openmaize plugs will just return the connection
  without performing any further checks.
  """
  def terminate(conn), do: conn |> put_private(:openmaize_skip, true) |> halt

  defp redirect_to(%Plug.Conn{resp_headers: resp_headers} = conn, address, message) do
    unless map_size(message) == 0, do: conn = add_message(conn, message)
    new_headers = [{"content-type", "text/html; charset=utf-8"}, {"location", address}]
    %{conn | resp_headers: new_headers ++ resp_headers}
    |> send_resp(302, "")
    |> terminate
  end

  defp redirect_to_login(conn, message) do
    redirect_to(conn, "#{Config.login_dir}/login", message)
  end

  defp add_message(conn, message) do
    if Map.get(conn.private, :phoenix_flash) do
      put_private(conn, :phoenix_flash, message)
    else
      IO.inspect message
      conn
    end
  end

end
