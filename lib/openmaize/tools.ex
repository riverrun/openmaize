defmodule Openmaize.Tools do
  @moduledoc """
  """

  import Plug.Conn
  alias Openmaize.Config

  def redirect(conn, address) do
    uri = "#{conn.scheme}://#{conn.host}#{address}"
    register_before_send(conn, &send_redirect_header(&1, uri))
  end

  def redirect_to_login(conn) do
    redirect(conn, Config.login_page) |> halt
  end

  defp send_redirect_header(conn, uri) do
    conn |> put_resp_header("location", uri) |> put_status(301)
  end
end
