defmodule Openmaize.Redirect do
  @moduledoc """
  Handle redirects and error / info reporting.
  """

  import Plug.Conn

  @doc """
  Redirect the connection and report errors / info.

  If you are using Phoenix, the error / info messages will be displayed
  on the screen - using Phoenix flash.
  """
  def redirect_to(%Plug.Conn{resp_headers: resp_headers} = conn, address, message) do
    new_headers = [{"content-type", "text/html; charset=utf-8"}, {"location", address}]
    %{conn | resp_headers: new_headers ++ resp_headers}
    |> print_message(message)
    |> send_resp(302, "")
    |> halt()
  end

  defp print_message(conn, message) do
    if Map.get(conn.private, :phoenix_flash) do
      put_private(conn, :phoenix_flash, message)
    else
      IO.inspect message
      conn
    end
  end
end
