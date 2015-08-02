defmodule Openmaize.Authorize.Base do
  @moduledoc """
  """

  import Plug.Conn
  import Openmaize.Report
  alias Openmaize.Config

  def permitted?({{0, _}, path}, nil) do
    {:error, "You have to be logged in to view #{path}"}
  end
  def permitted?(_, nil), do: {:ok, :nomatch}
  def permitted?({{0, match_len}, path}, %{role: role}) do
    match = :binary.part(path, {0, match_len})
    if role in Map.get(Config.protected, match) do
      {:ok, path, match}
    else
      {:error, role, "You do not have permission to view #{path}"}
    end
  end
  def permitted?(_, _), do: {:ok, :nomatch}

  def get_match(%Plug.Conn{request_path: path}) do
    {:binary.match(path, Map.keys(Config.protected)), path}
  end

  def authorized?({:ok, :nomatch}, conn, _), do: put_private(conn, :openmaize_skip, true)
  def authorized?({:ok, _path, _match}, conn, _), do: conn
  def authorized?({:error, message}, conn, {false, _}), do: send_error(conn, 401, message)
  def authorized?({:error, message}, conn, _), do: handle_error(conn, message)
  def authorized?({:error, _, message}, conn, {false, _}), do: send_error(conn, 403, message)
  def authorized?({:error, role, message}, conn, _), do: handle_error(conn, role, message)

end
