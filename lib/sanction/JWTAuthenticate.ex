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
    #get_req_header(conn, "authorization") |> IO.inspect
    case check_token(get_req_header(conn, "authorization")) do
      {:ok, data} -> send_resp(conn, 200, "")
      {:error, _message} -> raise InvalidTokenError
    end
  end

  defp check_token([token]), do: Joken.decode(token, Config.secret_key)
  defp check_token(_), do: raise InvalidTokenError
end
