defmodule Openmaize.Report do
  @moduledoc """
  This module provides error and info messages and handles redirects if
  the option `redirects` is set to true.

  If you are using Phoenix, then the error and info messages will be
  sent to `phoenix_flash` to be shown in the web browser.
  """

  import Plug.Conn
  import Openmaize.Redirect
  alias Openmaize.Config

  @doc """
  Handle authentication errors.

  These errors relate to there being no current user for a protected page.

  If redirects is set to true, the user will be redirected to the login
  page. If redirects is false, a json-encoded message will be sent to the
  user.
  """
  def handle_error(conn, message, true) do
    redirect_to(conn, "#{Config.redirect_pages["login"]}", %{"error" => message})
  end
  def handle_error(conn, message, false) do
    send_resp(conn, 401, Poison.encode!(%{"error" => message})) |> halt()
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
  def handle_error(conn, _role, message, false) do
    send_resp(conn, 403, Poison.encode!(%{"error" => message})) |> halt()
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

end
