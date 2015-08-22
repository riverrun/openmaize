defmodule Openmaize.Authorize.Base do
  @moduledoc """
  Base module to handle authorization, which is based on user role.

  This module provides functions that are called by the
  various authorization plugs.

  You can also define your own plugs, which can call the functions in
  this module. The `Openmaize.Authorize` and `Openmaize.Authorize.IdCheck`
  modules provide examples of how to write your own plugs.
  """

  import Openmaize.Report
  alias Openmaize.Config

  @doc """
  Function that performs a basic check to see if the path / resource is
  protected and if the user, based on role, is permitted to access the path.
  """
  def full_check(conn, opts, data) do
    get_match(conn) |> permitted?(data) |> authorized?(conn, opts)
  end

  @doc """
  Function that performs the same basic check as full_check, but does
  not call the `authorized?` function.

  This can be used by plugs that make further checks in addition to the
  basic authorization. See `Openmaize.Authorize.IdCheck` for an example
  of a plug that provides finer-grained authorization.
  """
  def part_check(conn, data) do
    get_match(conn) |> permitted?(data)
  end

  defp permitted?({{0, _}, path}, nil) do
    {:error, "You have to be logged in to view #{path}"}
  end
  defp permitted?(_, nil), do: {:ok, :nomatch}
  defp permitted?({{0, match_len}, path}, %{role: role}) do
    match = :binary.part(path, {0, match_len})
    if role in Map.get(Config.protected, match) do
      {:ok, path, match}
    else
      {:error, role, "You do not have permission to view #{path}"}
    end
  end
  defp permitted?(_, _), do: {:ok, :nomatch}

  defp get_match(%Plug.Conn{request_path: path}) do
    {:binary.match(path, Map.keys(Config.protected)), path}
  end

  @doc """
  Final step in the authorization process.

  If the connection is unprotected or if the user is allowed to access the
  path / resource, the connection, `conn`, is returned.

  If there is an error, then an error is returned with an error message.
  If the redirects option is set to true, then the user is redirected to a
  certain page (which is specified in the config).
  """
  def authorized?({:ok, :nomatch}, conn, _), do: conn
  def authorized?({:ok, _path, _match}, conn, _), do: conn
  def authorized?({:error, message}, conn, {false, _}), do: send_error(conn, 401, message)
  def authorized?({:error, message}, conn, _), do: handle_error(conn, message)
  def authorized?({:error, _, message}, conn, {false, _}), do: send_error(conn, 403, message)
  def authorized?({:error, role, message}, conn, _), do: handle_error(conn, role, message)

end
