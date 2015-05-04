defmodule Openmaize.Authenticate do
  @moduledoc """
  Module to authenticate users.

  JSON Web Tokens (JWTs) are used to authenticate the user.
  If there is no token or the token is invalid, the user will
  be redirected to the login page.

  ## Example

  In the main `router.ex` file,

  add the following line to the `pipeline :browser` function:

      plug :open_sesame

  and add the following function to the same file:

      def open_sesame(conn, opts \\ []) do
        Openmaize.Authenticate.call(conn, opts)
      end

  """

  import Plug.Conn
  alias Openmaize.Config
  alias Openmaize.Token
  alias Openmaize.Tools

  @behaviour Plug

  def init(opts), do: opts

  def call(conn, _opts) do
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
