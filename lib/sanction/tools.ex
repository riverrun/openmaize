defmodule Sanction.Tools do
  @moduledoc """
  """

  import Plug.Conn
  alias Sanction.Config

  def redirect_to_login(conn) do
    uri = "https://" <> conn.host <> Config.login_page
    conn
    |> put_resp_header("location", uri)
    |> send_resp(301, "")
  end

end
