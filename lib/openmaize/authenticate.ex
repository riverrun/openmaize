defmodule Openmaize.Authenticate do
  @moduledoc """
  Module to authenticate users.

  JSON Web Tokens (JWTs) are used to authenticate the user.
  If there is no token or the token is invalid, the user will
  be redirected to the login page.

  """

  import Plug.Conn
  import Openmaize.Tools
  alias Openmaize.Config
  alias Openmaize.Token

  @behaviour Plug

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_path(conn.path_info) do
      "/users/login" -> handle_login(conn)
      "/users/logout" -> handle_logout(conn)
      _ -> handle_auth(conn, Config.storage_method)
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

  defp handle_auth(conn, storage) when storage == "cookie" do
    conn = fetch_cookies(conn)
    Map.get(conn.req_cookies, "access_token") |> check_token(conn)
  end
  defp handle_auth(conn, _storage) do
    get_req_header(conn, "authorization") |> check_token(conn)
  end

  defp check_token(["Bearer " <> token], conn), do: check_token(token, conn)
  defp check_token(token, conn) when is_binary(token) do
    case Token.decode(token) do
      {:ok, data} -> verify_user(conn, data)
      {:error, message} -> redirect_to_login(conn, message)
    end
  end
  defp check_token(_, conn), do: redirect_to_login(conn, %{"error" => "Invalid credentials"})

  defp verify_user(conn, data) do
    role = Map.get(data, "role")
    if role == nil or role == "admin" or Enum.at(conn.path_info, 0) == "users" do
      assign(conn, :current_user, data)
    else
      redirect_to_login(conn, %{"error" => "You do not have permission to view this page"})
    end
  end

  defp get_path(path_info) do
    "/" <> Enum.join(path_info, "/")
  end
end
