defmodule Openmaize.Redirect do
  @moduledoc """
  Various tools that are used with Openmaize.
  """

  import Plug.Conn
  alias Openmaize.Config

  @doc """
  Function to redirect to a page with a message explaining why the user
  is being redirected.
  """
  def redirect_to(%{scheme: scheme, host: host} = conn, address, message) do
    if Mix.env == :dev, do: host = "localhost:4000"
    unless map_size(message) == 0, do: conn = send_message(conn, message)
    conn
    |> put_resp_header("location", "#{scheme}://#{host}#{address}")
    |> send_resp(301, "") |> halt
  end

  @doc """
  Redirect to the login page with a message explaining why the user
  is being redirected.
  """
  def redirect_to_login(conn, message) do
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
