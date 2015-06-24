defmodule Openmaize.Token do
  @moduledoc """
  Module to generate Json Web Tokens and send them to the user, either
  by storing the token in a cookie or sending the token in the body of
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

  If you do not store the token in a cookie, then you will not need to use
  the `protect_from_forgery` (csrf protection) plug. However, if you are
  storing the token in sessionStorage, there is then a risk of cross-site
  scripting attack.

  """

  import Plug.Conn
  import Openmaize.Errors
  alias Openmaize.Config

  @secret_key Config.secret_key
  @json_module Openmaize.JSON
  @algorithm :HS512

  @token_info Config.token_info

  @doc """
  Encode JWT.
  """
  def encode(payload, claims \\ %{}) do
    Joken.Token.encode(@secret_key, @json_module, payload, @algorithm, claims)
  end

  @doc """
  Decode JWT.
  """
  def decode(token, claims \\ %{}) do
    Joken.Token.decode(@secret_key, @json_module, token, @algorithm, claims)
  end

  @doc """
  Generate token based on the user information and the `token_info`
  setting in the config.

  The token is then either stored in a cookie or sent in the body of the
  response.
  """
  def add_token(user, conn, storage) when storage == :cookie do
    role = Map.get(user, :role)
    {:ok, token} = generate_token(user)
    put_resp_cookie(conn, "access_token", token, [http_only: true])
    |> handle_info(role, "You have been logged in")
  end
  def add_token(user, conn, _storage) do
    {:ok, token} = generate_token(user)
    token_string = ~s({"access_token": #{token}})
    send_resp(conn, 200, token_string) |> terminate
  end

  defp generate_token(user) do
    Map.take(user, @token_info)
    |> Map.merge(%{exp: token_expiry_secs})
    |> encode
  end

  defp token_expiry_secs do
    current_time + Config.token_validity
  end

  defp current_time do
    {mega, secs, _} = :os.timestamp
    mega * 1000000 + secs
  end
end
