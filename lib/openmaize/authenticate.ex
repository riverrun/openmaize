defmodule Openmaize.Authenticate do
  @moduledoc """
  Authenticate the current user, using JSON Web Tokens.

  For more information about JSON Web Tokens, see the documentation for
  the OpenmaizeJWT module.

  It is important to note that this module only checks the identity of
  the user. For authorization / access control, you need to perform
  further checks.

  There is one option:

  * jwt_verify - the function used to verify the JSON Web Token
    * the default is `&OpenmaizeJWT.Verify.verify_token/1`

  ## Examples using Phoenix

  Add the following line to the pipeline in the `web/router.ex` file:

      plug Openmaize.Authenticate

  """

  import Plug.Conn

  @behaviour Plug

  def init(opts) do
    Keyword.get(opts, :jwt_verify, &OpenmaizeJWT.Verify.verify_token/1)
  end

  @doc """
  Authenticate the current user using JSON Web Tokens.

  This function checks the token, which is either in a cookie or the
  request headers, and authenticates the user based on the information in
  the token.

  It also sets the current_user variable, which, if you are using
  Phoenix, can then be used in your templates. If no token is found, the
  current_user is set to nil.
  """
  def call(%Plug.Conn{req_cookies: %{"access_token" => token}} = conn, jwt_verify) do
    check_token(token, jwt_verify) |> set_current_user(conn)
  end
  def call(%Plug.Conn{req_headers: headers} = conn, jwt_verify) do
    case List.keyfind(headers, "authorization", 0) do
      {_, token} -> check_token(token, jwt_verify) |> set_current_user(conn)
      nil -> set_current_user(nil, conn)
    end
  end

  defp check_token("Bearer " <> token, jwt_verify), do: check_token(token, jwt_verify)
  defp check_token(token, jwt_verify) when is_binary(token), do: jwt_verify.(token)
  defp check_token(_, _), do: nil

  defp set_current_user({:ok, data}, conn), do: assign(conn, :current_user, data)
  defp set_current_user({:error, _}, conn), do: assign(conn, :current_user, nil)
  defp set_current_user(_, conn), do: assign(conn, :current_user, nil)
end
