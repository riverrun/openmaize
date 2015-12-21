defmodule Openmaize.Authenticate do
  @moduledoc """
  Plug to authenticate users, using Json Web Tokens.

  For more information about Json Web Tokens, see the documentation for
  the Openmaize.Token module.

  This module also sets the current_user variable, which, if you are using
  Phoenix, can then be used in your templates. If no token is found, the
  current_user is set to nil.

  There is one option:

  * storage - storage method for the token -- the default is :cookie
  Set the storage method to nil if you want to use sessionStorage or localStorage

  ## Examples

  Call Authenticate without any options (the token will be stored in a cookie):

      plug Openmaize.Authenticate

  Call Authenticate and send the token in the response body:

      plug Openmaize.Authenticate, storage: nil

  """

  import Plug.Conn
  import Openmaize.Token.Verify

  @behaviour Plug

  def init(opts), do: opts

  @doc """
  This function checks the token, which is either in a cookie or the
  request headers and authenticates the user based on the information in
  the token.

  If the authentication is successful, a map, called `:current_user`,
  providing the user information is added to the `assigns` map in the
  Plug connection. If there is no token, or if the token is invalid,
  the `:current_user` is set to nil.
  """
  def call(%Plug.Conn{private: %{openmaize_skip: true}} = conn, _opts), do: conn
  def call(conn, opts) do
    run(conn, Keyword.get(opts, :storage, :cookie))
  end
  defp run(conn, :cookie) do
    conn = fetch_cookies(conn)
    Map.get(conn.req_cookies, "access_token") |> check_token(conn)
  end
  defp run(%Plug.Conn{req_headers: headers} = conn, _opts) do
    get_token(headers) |> Enum.at(0) |> check_token(conn)
  end

  defp get_token(headers) do
    for {k, v} <- headers, k == "authorization" or k == "access-token", do: v
  end

  defp check_token("Bearer " <> token, conn), do: check_token(token, conn)
  defp check_token(token, conn) when is_binary(token) do
    case verify_token(token) do
      {:ok, data} -> assign(conn, :current_user, data)
      {:error, _message} -> assign(conn, :current_user, nil)
    end
  end
  defp check_token(_, conn) do
    assign(conn, :current_user, nil)
  end
end
