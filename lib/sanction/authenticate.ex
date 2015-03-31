defmodule Sanction.Authenticate do
  @moduledoc """
  """

  import Plug.Conn
  alias Sanction.Token

  defmodule InvalidTokenError do
    @moduledoc "Error raised when token is invalid."
    message = "Invalid token."
    defexception message: message, plug_status: 401
  end

  @behaviour Plug

  def init(opts), do: opts

  def call(conn, _opts) do
    conn = fetch_cookies(conn)
    case check_token(Map.get(conn.req_cookies, "access_token")) do
      {:ok, data} -> assign(conn, :authenticated_user, data)
      {:error, _message} -> raise InvalidTokenError
    end
  end

  defp check_token(token) when is_binary(token), do: Token.decode(token)
  defp check_token(_), do: raise InvalidTokenError
end
