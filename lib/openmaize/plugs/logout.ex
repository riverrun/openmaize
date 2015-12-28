defmodule Openmaize.Logout do
  @moduledoc """
  Plug to handle logout requests.

  ## Examples

  """

  import Plug.Conn
  import Openmaize.Report

  @behaviour Plug

  def init(opts), do: opts

  @doc """
  """
  def call(conn, opts) do
    {redirects, storage} = case Keyword.get(opts, :redirects, true) do
                             true -> {true, Keyword.get(opts, :storage, :cookie)}
                             false -> {false, nil}
                           end
    handle_logout(conn, {redirects, storage})
  end

  defp handle_logout(conn, opts),
    do: assign(conn, :current_user, nil) |> logout_user(opts)

  defp logout_user(conn, {_, nil}), do: conn
  defp logout_user(conn, {redirects, :cookie}) do
    delete_resp_cookie(conn, "access_token")
    |> handle_info("You have been logged out")
  end
end
