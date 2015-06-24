defmodule Openmaize.Authenticate do
  @moduledoc """
  Module to authenticate users, using Json Web Tokens.

  For more information about Json Web Tokens, see the documentation for
  the Openmaize.Token module.

  """

  import Plug.Conn
  import Openmaize.Errors
  alias Openmaize.Token

  @behaviour Plug

  def init(opts), do: opts

  @doc """
  This function checks the token, which is either in a cookie or the
  request headers and authenticates the user based on the information in
  the token.

  If the authentication is successful, a map, called `:current_user`,
  providing the user information is added to the `assigns` map in the
  Plug connection. If there is no token, the `:current_user` is set to nil.

  If there is an error, the user is either redirected to the login page
  or an error message is sent to the user. The connection is also halted.
  """
  def call(%{private: private} = conn, opts) do
    if Map.get(private, :openmaize_skip) == true do
      conn
    else
      opts = {Keyword.get(opts, :redirects), Keyword.get(opts, :storage, :cookie)}
      run(conn, opts)
    end
  end
  defp run(conn, {_, :cookie} = opts) do
    conn = fetch_cookies(conn)
    Map.get(conn.req_cookies, "access_token") |> check_token(conn, opts)
  end
  defp run(%{req_headers: headers} = conn, opts) do
    get_token(headers) |> Enum.at(0) |> check_token(conn, opts)
  end

  defp get_token(headers) do
    for {k, v} <- headers, k == "authorization" or k == "access-token", do: v
  end

  defp check_token("Bearer " <> token, conn, opts), do: check_token(token, conn, opts)
  defp check_token(token, conn, opts) when is_binary(token) do
    case Token.decode(token) do
      {:ok, data} -> assign(conn, :current_user, data)
      {:error, message} -> authenticate_error(conn, message, opts)
    end
  end
  defp check_token(_, conn, _) do
    assign(conn, :current_user, nil)
  end

  defp authenticate_error(conn, message, {false, _}) do
    send_error(conn, 401, message)
  end
  defp authenticate_error(conn, message, _), do: handle_error(conn, message)
end
