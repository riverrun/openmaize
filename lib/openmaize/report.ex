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
  Send a message for a user with no role.
  """
  def put_message(conn, message, true) do
    redirect_to(conn, "#{Config.redirect_pages["login"]}", message)
  end
  def put_message(conn, message, false) do
    send_resp(conn, 401, Poison.encode!(message)) |> halt()
  end

  @doc """
  Send a message for a user with a specific role.
  """
  def put_message(conn, role, message, true) do
    redirect_to(conn, "#{Config.redirect_pages[role]}", message)
  end
  def put_message(conn, _role, message, false) do
    send_resp(conn, 403, Poison.encode!(message)) |> halt()
  end
end
