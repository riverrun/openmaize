defmodule Openmaize.Logout do
  @moduledoc """
  Module to handle user logout.
  """

  import Plug.Conn
  import Openmaize.Redirect
  alias Openmaize.Config

  @behaviour Plug

  def init(opts), do: opts

  @doc """
  Function to handle user logout.

  The token is deleted and the user is redirected to the home page.
  """
  def call(conn, opts \\ []) do
    logout_user(conn, opts, Config.storage_method)
  end

  defp logout_user(conn, opts, storage) when storage == :cookie do
    delete_resp_cookie(conn, "access_token", opts)
    |> redirect_to("/", %{"info" => "You have been logged out"})
  end

  defp logout_user(conn, _opts, _storage) do
    #remove from sessionStorage
    conn
  end

end
