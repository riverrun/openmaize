defmodule Openmaize.Logout do
  @moduledoc """
  Module to handle user logout.
  """

  import Plug.Conn
  import Openmaize.Report

  @doc """
  Function to handle user logout.

  If the token is stored in a cookie, the cookie is deleted and the
  user is redirected to the home page.

  If the token is stored in sessionStorage, then you need to delete
  the token with the front-end framework you are using.
  """
  def call(conn, {false, _, _}), do: logout_user(conn, nil)
  def call(conn, {_, storage, _}), do: logout_user(conn, storage)

  defp logout_user(conn, storage) when storage == :cookie do
    delete_resp_cookie(conn, "access_token")
    |> handle_info("You have been logged out")
  end

  defp logout_user(conn, _storage) do
    conn
  end

end
