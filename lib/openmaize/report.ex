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
  Redirect the connection to the login page with an error message.
  """
  def handle_error(conn, message) do
    redirect_to_login(conn, %{"error" => message})
  end

  @doc """
  Redirect the connection to the user's role's page with an error message.
  """
  def handle_error(conn, role, message) do
    redirect_to(conn, "#{Config.redirect_pages[role]}", %{"error" => message})
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
  Send a json-encoded error message as a response and then halt the connection.
  This function will be used if the `redirects` option is set to false.
  """
  def send_error(conn, status, message) do
    send_resp(conn, status, Poison.encode!(%{"error" => message})) |> terminate
  end

  @doc """
  Return and halt the connection. Also, set the openmaize_skip value to true,
  which means that subsequent Openmaize plugs will just return the connection
  without performing any further checks.
  """
  def terminate(conn), do: conn |> put_private(:openmaize_skip, true) |> halt

  defp redirect_to(%{resp_headers: resp_headers} = conn, address, message) do
    unless map_size(message) == 0, do: conn = send_message(conn, message)
    new_headers = [{"content-type", "text/html; charset=utf-8"}, {"location", address}]
    %{conn | resp_headers: new_headers ++ resp_headers}
    |> send_resp(302, "")
    |> terminate
  end

  defp redirect_to_login(conn, message) do
    redirect_to(conn, "#{Config.login_dir}/login", message)
  end

  defp send_message(conn, message) do
    if Map.get(conn.private, :phoenix_flash) do
      put_private(conn, :phoenix_flash, message)
    else
      IO.inspect message
      conn
    end
  end

end
