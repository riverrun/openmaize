defmodule Openmaize do
  @moduledoc """
  """

  import Plug.Conn
  alias Openmaize.Authenticate
  alias Openmaize.Config
  alias Openmaize.Login
  alias Openmaize.Logout

  @behaviour Plug

  def init(opts), do: opts

  @doc """
  Function to check the token provided. If there is no token, or if the
  token is invalid, the user is redirected to the login page.

  If the path is for the login or logout page, the user is redirected
  to that page straight away.
  """
  def call(%{path_info: path_info} = conn, _opts) do
    case Enum.at(path_info, -1) do
      "login" -> handle_login(conn)
      "logout" -> handle_logout(conn)
      _ -> Authenticate.call(conn, [storage: Config.storage_method])
    end
  end

  defp handle_login(%{method: "POST"} = conn), do: Login.call(conn, [])
  defp handle_login(conn), do: assign(conn, :current_user, nil)

  defp handle_logout(conn), do: assign(conn, :current_user, nil) |> Logout.call([])

end
