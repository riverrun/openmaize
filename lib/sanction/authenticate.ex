defmodule Sanction.Authenticate do
  @moduledoc """
  """

  import Plug.Conn

  defmodule InvalidTokenError do
    @moduledoc "Error raised when token is invalid."
    message = "Invalid token."
    defexception message: message, plug_status: 401
  end

  @behaviour Plug

  def init(opts), do: opts

  def call(conn, opts) do
    name = Keyword.get(opts, :name, "access_token")
    token = Map.get(conn.req_cookies, name)
    case check_token(token) do
      {:ok, data} -> assign(conn, :authenticated_user, data)
      {:error, _message} -> raise InvalidTokenError
    end
  end

  defp check_token(nil), do: raise InvalidTokenError
  defp check_token(token), do: Token.decode(token)
end
