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

  @doc """
  """
  def call(conn, [storage: "cookie"]) do
    conn = fetch_cookies(conn)
    Map.get(conn.req_cookies, "access_token") |> check_token(conn)
  end

  @doc """
  """
  def call(conn, _opts) do
    get_req_header(conn, "authorization") |> check_token(conn)
  end

  defp check_token(["Bearer " <> token], conn), do: check_token(token, conn)
  defp check_token(token, conn) when is_binary(token) do
    case Token.decode(token) do
      {:ok, data} -> verify_user(conn, data)
      {:error, message} -> redirect_to_login(conn, %{"error" => message})
    end
  end
  defp check_token(_, %{path_info: path_info} = conn) do
    if Enum.at(path_info, 0) in Config.protected do
      redirect_to_login(conn, %{})
    else
      assign(conn, :current_user, nil)
    end
  end

  defp verify_user(conn, data) do
    assign(conn, :current_user, data)
  end

end
