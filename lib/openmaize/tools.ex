defmodule Openmaize.Tools do
  @moduledoc """
  """

  import Plug.Conn
  alias Openmaize.Config

  def redirect_page(conn, address) do
    uri = "#{conn.scheme}://#{conn.host}#{address}"
    conn |> put_resp_header("location", uri) |> send_resp(301, "") |> halt
  end

  def redirect_to_login(conn) do
    redirect_page(conn, Config.login_page)
  end

end
