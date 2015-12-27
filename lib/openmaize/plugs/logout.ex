defmodule Openmaize.Logout do
  @moduledoc """
  Plug to handle login and logout requests.
  """

  import Plug.Conn
  import Openmaize.Report

  @behaviour Plug

  def init(opts), do: opts

  @doc """
  """
  def call(conn, opts) do
    handle_logout(conn, Keyword.get(opts, :storage, :cookie))
  end

  defp handle_logout(conn, storage),
    do: assign(conn, :current_user, nil) |> logout_user(storage)

  defp logout_user(conn, nil), do: conn
  defp logout_user(conn, :cookie) do
    delete_resp_cookie(conn, "access_token")
    |> handle_info("You have been logged out")
  end
end
