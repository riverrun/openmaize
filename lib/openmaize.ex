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
  import Openmaize.Errors
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
  def call(%{path_info: path_info} = conn, opts) do
    case Enum.at(path_info, -1) do
      "login" -> handle_login(conn, opts)
      "logout" -> handle_logout(conn, opts)
      _ -> handle_auth(conn, opts)
    end
  end

  defp handle_login(%{method: "POST"} = conn, opts), do: Login.call(conn, opts)
  defp handle_login(conn, _opts), do: assign(conn, :current_user, nil)

  defp handle_logout(conn, opts), do: assign(conn, :current_user, nil) |> Logout.call(opts)

  defp handle_auth(conn, [redirects: false]) do
    auth_worker(conn, [redirects: false])
  end
  defp handle_auth(conn, _opts), do: auth_worker(conn, [storage: Config.storage_method])

  defp auth_worker(conn, opts) do
    case Authenticate.call(conn, opts) do
      {:ok, data} -> assign(conn, :current_user, data)
      {:error, message} -> auth_error(conn, message, opts)
      {:error, role, message} -> role_error(conn, role, message, opts)
    end
  end

  defp auth_error(conn, message, [redirects: false]), do: send_error(conn, 401, message)
  defp auth_error(conn, message, _), do: handle_error(conn, message)

  defp role_error(conn, _, message, [redirects: false]), do: send_error(conn, 403, message)
  defp role_error(conn, role, message, _), do: handle_error(conn, role, message)

end
