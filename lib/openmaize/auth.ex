defmodule Openmaize.Auth do
  @moduledoc """
  Module to authenticate users, using Json Web Tokens, and verify that they
  are authorized to access the requested pages.

  Authorization is based on user roles, and so you will need a `role` entry
  in your user model.

  For more information about Json Web Tokens, see the documentation for
  the Openmaize.Token module.

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
