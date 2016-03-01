defmodule Openmaize.Authenticate do
  @moduledoc """
  Plug to authenticate users, using JSON Web Tokens.

  For more information about JSON Web Tokens, see the documentation for
  the Openmaize.JWT module.

  It is important to note that this module only checks the identity of
  the user. For authorization / access control, you need to perform
  further checks - see the Openmaize.AccessControl module for more
  information.

  ## Examples using Phoenix

  Add the following line to the pipeline in the `web/router.ex` file:

      plug Openmaize.Authenticate

  """

  import Plug.Conn
  import Openmaize.JWT.Verify

  @behaviour Plug

  def init(opts), do: opts

  @doc """
  Authenticate the user using JSON Web Tokens.

  This function checks the token, which is either in a cookie or the
  request headers, and authenticates the user based on the information in
  the token.

  It also sets the current_user variable, which, if you are using
  Phoenix, can then be used in your templates. If no token is found, the
  current_user is set to nil.
  """
  def call(%Plug.Conn{req_cookies: %{"access_token" => token}} = conn, _opts) do
    check_token(token) |> set_current_user(conn)
  end
  def call(%Plug.Conn{req_headers: headers} = conn, _opts) do
    case List.keyfind(headers, "authorization", 0) do
      {_, token} -> check_token(token) |> set_current_user(conn)
      nil -> set_current_user(nil, conn)
    end
  end

  defp check_token("Bearer " <> token), do: check_token(token)
  defp check_token(token) when is_binary(token), do: verify_token(token)
  defp check_token(_), do: nil

  defp set_current_user({:ok, data}, conn), do: assign(conn, :current_user, data)
  defp set_current_user({:error, _}, conn), do: assign(conn, :current_user, nil)
  defp set_current_user(nil, conn), do: assign(conn, :current_user, nil)
end
