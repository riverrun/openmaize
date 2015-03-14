defmodule Sanction.Plug do
  @moduledoc """
  """

  import Plug.Conn

  @behaviour Plug

  defmodule InvalidTokenError do
    @moduledoc "Error raised when token is invalid."
    message = "Invalid token."
    defexception message: message, plug_status: 403
  end

  def init(opts), do: opts

  def call(conn, opts) do
    case check_token(get_req_header(conn, "authorization")) do
      {:ok, data} -> assign(conn, :authenticated_user, data)
      {:error, message} -> send_resp(conn, 403, Poison.encode!(%{error: message})) |> halt
    end
  end

  defp check_token(token), do: Joken.decode(token, secret_key)
  defp check_token(_), do: {:error, "Not authorized"}

end
