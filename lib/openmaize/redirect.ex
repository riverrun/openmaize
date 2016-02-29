defmodule Openmaize.Redirect do
  @moduledoc """
  Handle redirects and error / info reporting.
  """

  import Plug.Conn

  @doc """
  Redirect the connection and report errors / info.

  If you are using Phoenix, the error / info messages will be displayed
  on the screen - using Phoenix flash. If you are not using Phoenix, these
  messages will be stored in `private.openmaize_info` in the conn struct.
  """
  def redirect_to(%Plug.Conn{resp_headers: resp_headers} = conn, path, message) do
    if String.contains?(path, "/:"), do: path = set_id(conn, path)
    new_headers = [{"content-type", "text/html; charset=utf-8"}, {"location", path}]
    %{conn | resp_headers: new_headers ++ resp_headers}
    |> log_message(message)
    |> send_resp(302, "")
    |> halt()
  end

  defp set_id(%Plug.Conn{assigns: %{current_user: current_user}}, path) do
    String.replace(path, "/:id", "/" <> to_string(current_user.id))
  end

  defp log_message(conn, message) do
    if Map.get(conn.private, :phoenix_flash) do
      put_private(conn, :phoenix_flash, message)
    else
      put_private(conn, :openmaize_info, message)
    end
  end
end
