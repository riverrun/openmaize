defmodule Sanction.Tools do
  @moduledoc """
  """

  import Plug.Conn
  alias Sanction.Config

  def redirect_to_login(conn) do
    conn
    |> put_resp_header("location", Config.login_page)
    |> send_resp(301, "")
  end

end
