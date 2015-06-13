defmodule Openmaize.Errors do
  @moduledoc """
  Module to handle errors and redirects.
  """

  import Plug.Conn
  alias Openmaize.Config
  alias Openmaize.JSON

  def handle_error(conn, message) do
    redirect_to_login(conn, %{"error" => message})
  end

  def handle_error(conn, role, message) do
    redirect_to(conn, "#{Config.redirect_pages[role]}", %{"error" => message})
  end

  def handle_info(conn, message), do: redirect_to(conn, "/", %{"info" => message})

  def handle_info(conn, role, message) do
    redirect_to(conn, "#{Config.redirect_pages[role]}", %{"info" => message})
  end

  def send_error(conn, message) do
    send_resp(conn, 401, JSON.encode(message)) |> halt
  end

  defp redirect_to(%{scheme: scheme, host: host} = conn, address, message) do
    if Mix.env == :dev, do: host = "localhost:4000"
    unless map_size(message) == 0, do: conn = send_message(conn, message)
    conn
    |> put_resp_header("location", "#{scheme}://#{host}#{address}")
    |> send_resp(301, "") |> halt
  end

  defp redirect_to_login(conn, message) do
    redirect_to(conn, "#{Config.login_dir}/login", %{"error" => message})
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
