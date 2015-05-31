defmodule Openmaize do
  @moduledoc """
  This module handles the initial call to Openmaize and then calls the
  relevant module for handling authentication, logging in or logging
  out.

  If the path is for the login page and the method is "POST", the
  connection is redirected to the Openmaize.Login module. If the
  method is "GET", the current user is given a nil value, and then
  the connection is returned.

  If the path is for the logout page, the connection is redirected
  to the Openmaize.Logout module, which handles the logout and redirects
  the user to the home page.

  For any other path, including unprotected paths, the connection is
  redirected to the Openmaize.Authenticate module, which handles
  authentication.

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
