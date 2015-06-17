defmodule Openmaize.Logout do
  @moduledoc """
  Module to handle user logout.
  """

  import Plug.Conn
  import Openmaize.Errors
  alias Openmaize.Config

  @doc """
  Function to handle user logout.

  If the token is stored in a cookie, the cookie is deleted and the
  user is redirected to the home page.
  """
  def call(conn, {false, _}), do: logout_user(conn, :session)
  def call(conn, _opts), do: logout_user(conn, Config.storage_method)

  defp logout_user(conn, storage) when storage == :cookie do
    delete_resp_cookie(conn, "access_token")
    |> handle_info("You have been logged out")
  end

  defp logout_user(conn, _storage) do
    conn
  end

end
