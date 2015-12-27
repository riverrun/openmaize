defmodule Openmaize.Phoenix.Tools do
  @moduledoc """
  Various tools that are used with the management of JSON Web Tokens.
  """

  import Plug.Conn

  def redirect_to(%Plug.Conn{resp_headers: resp_headers} = conn, address, message) do
    new_headers = [{"content-type", "text/html; charset=utf-8"}, {"location", address}]
    %{conn | resp_headers: new_headers ++ resp_headers}
    |> print_message(message)
    |> send_resp(302, "")
    |> halt()
  end

  defp print_message(conn, message) do
    IO.inspect message
    conn
  end
end
