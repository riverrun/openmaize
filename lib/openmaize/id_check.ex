defmodule Openmaize.IdCheck do
  @moduledoc """
  This module contains functions that can perform extra checks.

  They can be used as they are, but they also serve as examples of
  how to write such functions.
  """

  alias Openmaize.Config

  @protected Map.keys(Config.protected)

  @doc """
  Function to not allow a user to edit another user's page. However,
  the user is allowed to view the page.
  """
  def id_noedit(_conn, %{id: id, role: role} = data, path, match) do
    case verify_id(path, id, match, "/") do
      true -> {:ok, data}
      false -> {:error, role, "You do not have permission to view #{path}"}
    end
  end

  @doc """
  Function to not allow a user to view another user's page.
  """
  def id_noshow(_conn, %{id: id, role: role} = data, path, match) do
    case verify_id(path, id, match, "") do
      true -> {:ok, data}
      false -> {:error, role, "You do not have permission to view #{path}"}
    end
  end

  defp verify_id(path, id, match, suffix) when (match <> "/:id") in @protected do
    if Regex.match?(~r{#{match}/[0-9]+(/|$)}, path) do
      Kernel.match?({0, _}, :binary.match(path, "#{match}/#{id}#{suffix}"))
    else
      true
    end
  end
  defp verify_id(_, _, _, _), do: true

end
