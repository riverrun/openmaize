defmodule Openmaize do
  @moduledoc """
  This module handles the initial call to Openmaize and then calls the
  relevant module for handling authentication, logging in or logging
  out.

  If the path is for the login page and the method is "POST", the
  connection is redirected to the Openmaize.Login module. If the
  method is "GET", the user is allowed to go to the login page.

  If the path is for the logout page, the connection is redirected
  to the Openmaize.Logout module, which handles the logout and redirects
  the user to the home page.

  For any other path, including unprotected paths, the connection is
  redirected to the Openmaize.Authenticate module, which handles
  authentication.

  ## Phoenix integration

  The `current_user` variable is set for every path. This means that
  you can access `@current_user` in any of your templates. If nobody
  is logged in, `current_user` is set to nil.

  """

  import Plug.Conn
  alias Openmaize.Authenticate
  alias Openmaize.Config
  alias Openmaize.Login
  alias Openmaize.Logout

  @behaviour Plug
  @login_dir Config.login_dir

  def init(opts), do: opts

  @doc """
  Function to check the token provided. If there is no token, or if the
  token is invalid, the user is redirected to the login page.

  If the path is for the login or logout page, the user is redirected
  to that page straight away.
  """
  def call(conn, _opts) do
    case full_path(conn) do
      @login_dir <> "/login" -> handle_login(conn)
      @login_dir <> "/logout" -> handle_logout(conn)
      _ -> Authenticate.call(conn, [storage: Config.storage_method])
    end
  end

  defp handle_login(%{method: "POST"} = conn), do: Login.call(conn, [])
  defp handle_login(conn), do: assign(conn, :current_user, nil)

  defp handle_logout(conn), do: assign(conn, :current_user, nil) |> Logout.call([])

end
