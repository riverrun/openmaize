defmodule Openmaize.IdCheck do
  @moduledoc """
  This module contains functions that can perform optional checks
  based on the user id.

  They can be used as they are, but they also serve as examples of
  how to write such functions.

  For these functions to work, you need to have the start of the path
  and the start of the path + "/:id" in the protected map in the config.
  For example, the following entry protects "/users" and checks ids under
  "/users":

      config: openmaize,
        protected: %{"/users" => ["user"], "/users/:id" => ["user"]}

  """

  alias Openmaize.Config

  @protected Map.keys(Config.protected)

  @doc """
  Function to protect another user's page from editing. However,
  the user is allowed to view the page.
  """
  def id_noedit(_conn, data, path, match) when (match <> "/:id") in @protected do
    if Regex.match?(~r{#{match}/[0-9]+/}, path) do
      check_match(data, path, match, "/")
    else
      {:ok, data}
    end
  end
  def id_noedit(_, data, _, _), do: {:ok, data}

  @doc """
  Function to protect another user's page. In this case, the page cannot
  be viewed as well.
  """
  def id_noshow(_conn, data, path, match) when (match <> "/:id") in @protected do
    if Regex.match?(~r{#{match}/[0-9]+(/|$)}, path) do
      check_match(data, path, match, "")
    else
      {:ok, data}
    end
  end
  def id_noshow(_, data, _, _), do: {:ok, data}

  defp check_match(%{id: id, role: role} = data, path, match, suffix) do
    if Kernel.match?({0, _}, :binary.match(path, "#{match}/#{id}#{suffix}")) do
      {:ok, data}
    else
      {:error, role, "You do not have permission to view #{path}"}
    end
  end

end
