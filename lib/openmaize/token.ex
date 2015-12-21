defmodule Openmaize.Token do
  @moduledoc """
  Module to generate Json Web Tokens and send them to the user, either
  by storing the token in a cookie or by sending the token in the body of
  the response.

  ## Json Web Tokens

  Json Web Tokens (JWTs) are an alternative to using cookies to identify,
  and provide information about, users after they have logged in.

  One main advantage of using JWTs is that there is no need to keep a
  session store as the token can be used to contain user information.
  It is important, though, not to keep sensitive information in the
  token as the information is not encrypted -- it is just encoded.

  The JWTs need to be stored somewhere, either in cookies or sessionStorage
  (or localStorage), so that they can be used in subsequent requests.
  If you want to store the token in sessionStorage, you will need to add
  the token to sessionStorage with the front-end framework you are using
  and add the token to the request headers for each request.

  If you decide to store the token in sessionStorage, and not in a cookie,
  you will not need to use the `protect_from_forgery` (csrf protection) plug.
  However, storing tokens in sessionStorage opens up the risk of cross-site
  scripting attacks.

  """

  import Plug.Conn
  import Openmaize.Report
  import Openmaize.Token.Create

  @doc """
  Generate token based on the user information.

  The token is then either stored in a cookie or sent in the body of the
  response.
  """
  def add_token(conn, user, opts, storage) when storage == :cookie do
    role = Map.get(user, :role)
    {:ok, token} = generate_token(user, opts)
    put_resp_cookie(conn, "access_token", token, [http_only: true])
    |> handle_info(role, "You have been logged in")
  end
  def add_token(conn, user, opts, _storage) do
    {:ok, token} = generate_token(user, opts)
    token_string = ~s({"access_token": "#{token}"})
    send_resp(conn, 200, token_string) |> terminate
  end

end
