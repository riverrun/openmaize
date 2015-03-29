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
    case check_token(get_req_header(conn, "authorization")) do
      {:ok, data} -> assign(conn, :authenticated_user, data)
      {:error, _message} -> raise InvalidTokenError
    end
  end

  defp check_token(["Bearer " <> token]), do: Token.decode(token)
  defp check_token(_), do: raise InvalidTokenError
end
