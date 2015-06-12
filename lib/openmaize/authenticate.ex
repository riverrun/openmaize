defmodule Openmaize.Authenticate do
  @moduledoc """
  Module to authenticate users.

  JSON Web Tokens (JWTs) are used to authenticate the user.
  For protected pages, if there is no token or the token is
  invalid, the user will be redirected to the login page.

  ## JSON Web Tokens

  """

  import Plug.Conn
  import Openmaize.Errors
  alias Openmaize.Config
  alias Openmaize.Token

  @behaviour Plug
  @protected_roles Config.protected
  @protected Map.keys(Config.protected)

  def init(opts), do: opts

  @doc """
  This function is for when the token is stored in a cookie, which is
  the default method.
  """
  def call(conn, [storage: :cookie]) do
    conn = fetch_cookies(conn)
    Map.get(conn.req_cookies, "access_token") |> check_token(conn)
  end

  @doc """
  This function is for when the token is sent in the request header.
  """
  def call(%{req_headers: headers} = conn, _opts) do
    [token] = for {k, v} <- headers, k == "authorization" or k == "access-token", do: v
    check_token(token, conn)
  end

  defp check_token("Bearer " <> token, conn), do: check_token(token, conn)
  defp check_token(token, conn) when is_binary(token) do
    case Token.decode(token) do
      {:ok, data} -> verify_user(conn, data)
      {:error, message} -> handle_errors(conn, message)
    end
  end
  defp check_token(_, conn) do
    case full_path(conn) |> :binary.match(@protected) do
      {0, _} -> handle_errors(conn, "")
      _ -> assign(conn, :current_user, nil)
    end
  end

  defp verify_user(conn, data) do
    case full_path(conn) |> :binary.match(@protected) do
      {0, match_len} ->
        verify_role(conn, data, full_path(conn), match_len)
        _ -> assign(conn, :current_user, data)
    end
  end

  defp verify_role(conn, %{role: "admin"} = data, _path, _match_len) do
    assign(conn, :current_user, data)
  end
  defp verify_role(conn, %{id: id, role: role} = data, path, match_len) do
    match = :binary.part(path, {0, match_len})
    if role in Map.get(@protected_roles, match) and verify_id(path, match, id) do
      assign(conn, :current_user, data)
    else
      handle_errors(conn, role, "You do not have permission to view #{full_path(conn)}")
    end
  end

  defp verify_id(path, match, id) when (match <> "/:id") in @protected do
    if Regex.match?(~r{#{match}/[0-9]+/}, path) do
      Kernel.match?({0, _}, :binary.match(path, match <> "/#{id}/"))
    else
      true
    end
  end
  defp verify_id(_, _, _), do: true

end
