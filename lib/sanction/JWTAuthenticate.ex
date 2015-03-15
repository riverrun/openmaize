defmodule Sanction.JWTAuthenticate do
  @moduledoc """
  """

  import Plug.Conn
  alias Sanction.Config

  @behaviour Plug

  defmodule InvalidTokenError do
    @moduledoc "Error raised when token is invalid."
    message = "Invalid token."
    defexception message: message, plug_status: 403
  end

  def init(opts), do: opts

  def call(conn, _opts) do
    case check_token(get_req_header(conn, "authorization")) do
      {:ok, data} -> assign(conn, :authenticated_user, data)
      {:error, _message} -> raise InvalidTokenError
    end
  end

  defp check_token(["Bearer " <> token]), do: Joken.decode(token, Config.secret_key)
  defp check_token(_), do: raise InvalidTokenError
end
