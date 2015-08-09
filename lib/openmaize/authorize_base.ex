defmodule Openmaize.Authorize.Base do
  @moduledoc """
  Base module to handle authorization.

  This module provides functions that are called by the
  various authorization `Plugs`.
  """

  import Plug.Conn
  import Openmaize.Report
  alias Openmaize.Config

  @doc """
  Function that performs a basic check to see if the path / resource is
  protected and if the user is permitted to access the path.
  """
  def full_check(conn, opts, data) do
    get_match(conn) |> permitted?(data) |> authorized?(conn, opts)
  end

  @doc """
  Function that performs the same basic check as full_check, but does
  not call the `authorized?` function.

  This can be used by Plugs that make further checks in addition to the
  basic authorization. See `Openmaize.Authorize.IdCheck` for an example
  of a Plug that provides finer-grained authorization.
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
  """
  def authorized?({:ok, :nomatch}, conn, _), do: put_private(conn, :openmaize_skip, true)
  def authorized?({:ok, _path, _match}, conn, _), do: conn
  def authorized?({:error, message}, conn, {false, _}), do: send_error(conn, 401, message)
  def authorized?({:error, message}, conn, _), do: handle_error(conn, message)
  def authorized?({:error, _, message}, conn, {false, _}), do: send_error(conn, 403, message)
  def authorized?({:error, role, message}, conn, _), do: handle_error(conn, role, message)

end
