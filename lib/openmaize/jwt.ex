defmodule Openmaize.JWT do
  @moduledoc """
  Module to generate JSON Web Tokens and send them to the user, either
  by storing the token in a cookie or by sending the token in the body of
  the response.

  ## JSON Web Tokens

  JSON Web Tokens (JWTs) are an alternative to using cookies to identify,
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
  import Openmaize.JWT.Create
  alias Openmaize.Config

  @doc """
  Generate token based on the user information.

  The token is then either stored in a cookie or sent in the body of the
  response.
  """
  def add_token(conn, user, {:cookie, uniq}) do
    {:ok, token} = generate_token(user, uniq, {0, Config.token_validity})
    conn
    |> put_private(:openmaize_info, "You have been logged in")
    |> put_resp_cookie("access_token", token, [http_only: true])
  end
  def add_token(conn, user, {nil, uniq}) do
    {:ok, token} = generate_token(user, uniq, {0, Config.token_validity})
    conn
    |> put_private(:openmaize_info, "You have been logged in")
    |> resp(200, ~s({"access_token": "#{token}"}))
  end
end
