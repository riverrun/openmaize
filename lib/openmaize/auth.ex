defmodule Openmaize.Auth do
  @moduledoc """
  Module to authenticate users, using Json Web Tokens, and verify that they
  are authorized to access the requested pages.

  Authorization is based on user roles, and so you will need a `role` entry
  in your user model.

  ## Json Web Tokens

  Json Web Tokens (JWTs) are an alternative to using cookies to identify,
  and provide information about, users after they have logged in.

  One main advantage of using JWTs is that there is no need to keep a
  session store as the token can be used to contain user information.
  It is important, though, not to keep sensitive information in the
  token as the information is not encrypted -- it is just encoded.

  The JWTs need to be stored somewhere, either in cookies or sessionStorage
  (or localStorage), so that they can be used in subsequent requests. 
  With this module, if you store the token in a cookie, this module handles
  all of the authentication and authorization process. If, however, you want
  to store the token in sessionStorage, you will need to add the token to
  sessionStorage with the front-end framework you are using and add the
  token to the request headers for each request.

  If you do not store the token in a cookie, then you will probably not need
  to use the `protect_from_forgery` (csrf protection) plug.

  """

  import Plug.Conn
  alias Openmaize.Config
  alias Openmaize.Token

  @protected_roles Config.protected
  @protected Map.keys(Config.protected)

  @doc """
  This function checks the token, which is either in a cookie or the
  request headers, authenticates the user based on the information in
  the token and checks, based on the user's role, that the user is allowed
  to access the url.
  """
  def call(conn, [storage: :cookie]) do
    conn = fetch_cookies(conn)
    Map.get(conn.req_cookies, "access_token") |> check_token(conn)
  end
  def call(%{req_headers: headers} = conn, _opts) do
    get_token(headers) |> Enum.at(0) |> check_token(conn)
  end

  defp get_token(headers) do
    for {k, v} <- headers, k == "authorization" or k == "access-token", do: v
  end

  defp check_token("Bearer " <> token, conn), do: check_token(token, conn)
  defp check_token(token, conn) when is_binary(token) do
    case Token.decode(token) do
      {:ok, data} -> get_match(conn) |> is_permitted(data)
      {:error, message} -> {:error, message}
    end
  end
  defp check_token(_, conn) do
    get_match(conn) |> is_permitted(nil)
  end

  defp is_permitted({{0, _}, path}, nil) do
    {:error, "You have to be logged in to view #{path}"}
  end
  defp is_permitted(_, nil), do: {:ok, nil}
  defp is_permitted({{0, match_len}, path}, %{role: role} = data) do
    match = :binary.part(path, {0, match_len})
    if role in Map.get(@protected_roles, match) do
      {:ok, data, path, match}
    else
      {:error, role, "You do not have permission to view #{path}"}
    end
  end
  defp is_permitted(_, data), do: {:ok, data}

  defp get_match(conn) do
    path = full_path(conn)
    {:binary.match(path, @protected), path}
  end
end
