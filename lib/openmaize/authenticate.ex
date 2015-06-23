defmodule Openmaize.Authenticate do
  @moduledoc """
  Module to authenticate users, using Json Web Tokens.

  For more information about Json Web Tokens, see the documentation for
  the Openmaize.Token module.

  """

  import Plug.Conn
  alias Openmaize.Token

  @behaviour Plug

  def init(opts), do: opts

  @doc """
  This function checks the token, which is either in a cookie or the
  request headers and authenticates the user based on the information in
  the token.
  """
  def call(conn, [storage: :cookie]) do
    conn = fetch_cookies(conn)
    Map.get(conn.req_cookies, "access_token") |> check_token(conn)
  end
  def call(%{req_headers: headers} = conn, _opts) do
    get_token(headers) |> Enum.at(0) |> check_token(conn)
  end

  defp get_token(headers) do
    for {k, v} <- headers, k == "authorization" or k == "access-token", do: v
  end

  defp check_token("Bearer " <> token, conn), do: check_token(token, conn)
  defp check_token(token, conn) when is_binary(token) do
    case Token.decode(token) do
      {:ok, data} -> assign(conn, :current_user, data)
      {:error, message} -> {:error, message}
    end
  end
  defp check_token(_, conn) do
    assign(conn, :current_user, nil)
  end
end
