defmodule Openmaize.Authenticate do
  @moduledoc """
  Module to authenticate users.

  JSON Web Tokens (JWTs) are used to authenticate the user.
  If there is no token or the token is invalid, the user will
  be redirected to the login page.

  """

  import Plug.Conn
  alias Openmaize.Config
  alias Openmaize.Token
  alias Openmaize.Tools

  @behaviour Plug

  def init(opts), do: opts

  def call(conn, _opts) do
    cond do
      "login" in conn.path_info -> handle_login(conn)
      "logout" in conn.path_info -> handle_logout(conn)
      true -> handle_auth(conn)
    end
  end

  defp handle_login(conn) do
    if conn.method == "POST" do
      Openmaize.Login.call(conn, [])
    else
      conn
    end
  end

  defp handle_logout(conn), do: Openmaize.Logout.call(conn, [])

  defp handle_auth(conn) do
    if Config.storage_method == "cookie" do
      conn = fetch_cookies(conn)
      Map.get(conn.req_cookies, "access_token") |> check_token(conn)
    else
      get_req_header(conn, "authorization") |> check_token(conn)
    end
  end

  defp check_token(["Bearer " <> token], conn), do: check_token(token, conn)
  defp check_token(token, conn) when is_binary(token) do
    case Token.decode(token) do
      {:ok, data} -> assign(conn, :authenticated_user, data)
      {:error, _message} -> Tools.redirect_to_login(conn)
    end
  end
  defp check_token(_, conn), do: Tools.redirect_to_login(conn)
end
