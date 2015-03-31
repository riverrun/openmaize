defmodule Sanction.Authenticate do
  @moduledoc """
  """

  import Plug.Conn
  alias Sanction.Config
  alias Sanction.Token

  defmodule InvalidTokenError do
    @moduledoc "Error raised when token is invalid."
    message = "Invalid token."
    defexception message: message, plug_status: 401
  end

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
      {:error, _message} -> raise InvalidTokenError
    end
  end
  defp check_token(_, _), do: raise InvalidTokenError
end
