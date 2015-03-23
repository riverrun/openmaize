defmodule Sanction.Authenticate do
  @moduledoc """
  """

  import Plug.Conn
  import Sanction.Config

  defmodule InvalidTokenError do
    @moduledoc "Error raised when token is invalid."
    message = "Invalid token."
    defexception message: message, plug_status: 401
  end

  @behaviour Plug

  def init(opts), do: opts

  def call(conn, opts) do
    opts |> IO.inspect
    name = Keyword.get(opts, :name, "access_token")
    token = Map.get(conn.req_cookies, name)
    case check_token(token) do
      {:ok, data} -> assign(conn, :authenticated_user, data)
      {:error, _message} -> raise InvalidTokenError
    end
  end

  defp check_token([token]), do: Joken.decode(token, secret_key)
  defp check_token(_), do: raise InvalidTokenError
end
