defmodule Openmaize.Authenticate do
  @moduledoc """
  Plug to authenticate users, using Json Web Tokens.

  For more information about Json Web Tokens, see the documentation for
  the Openmaize.Token module.

  This module also sets the current_user variable, which, if you are using
  Phoenix, can then be used in your templates. If no token is found, the
  current_user is set to nil.

  There are two options:
  * redirects
      * if true, which is the default, redirect on login / logout
  * storage
      * storage method for the token -- the default is :cookie
      * if redirects is set to false, storage is automatically set to nil

  ## Examples

  Call Authenticate without any options:

      plug Openmaize.Authenticate

  Call Authenticate and send the token in the response body:

      plug Openmaize.Authenticate, storage: nil

  Call Authenticate without redirects:

      plug Openmaize.Authenticate, redirects: false

  """

  import Plug.Conn
  import Openmaize.Token.Verify
  import Openmaize.Report
  alias Openmaize.Config

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
  def call(%Plug.Conn{private: %{openmaize_skip: true}} = conn, _opts), do: conn
  def call(conn, opts) do
    opts = case Keyword.get(opts, :redirects, true) do
             true -> {true, Keyword.get(opts, :storage, :cookie)}
             false -> {false, nil}
    end
    run(conn, opts)
  end
  defp run(conn, {_, :cookie} = opts) do
    conn = fetch_cookies(conn)
    Map.get(conn.req_cookies, "access_token") |> check_token(conn, opts)
  end
  defp run(%Plug.Conn{req_headers: headers} = conn, opts) do
    get_token(headers) |> Enum.at(0) |> check_token(conn, opts)
  end

  defp get_token(headers) do
    for {k, v} <- headers, k == "authorization" or k == "access-token", do: v
  end

  defp check_token("Bearer " <> token, conn, opts), do: check_token(token, conn, opts)
  defp check_token(token, conn, opts) when is_binary(token) do
    case verify_token(token) do
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
  defp authenticate_error(%Plug.Conn{request_path: path} = conn, message, _) do
    case :binary.match(path, Map.keys(Config.protected)) do
      {0, _} -> handle_error(conn, message)
      _ -> assign(conn, :current_user, nil)
    end
  end
end
