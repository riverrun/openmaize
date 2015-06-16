defmodule Openmaize.ExtraCheck do
  @moduledoc """
  """

  import Plug.Conn

  def id_check(conn, %{role: role} = data) do
    case verify_id(conn, data) do
      true -> {:ok, data}
      false -> {:error, role, "You cannot view this page."}
    end
  end

  def verify_id(conn, %{id: id}) do
    path = full_path(conn)
    if Regex.match?(~r{/users/[0-9]+/}, path) do
      Kernel.match?({0, _}, :binary.match(path, "/users/#{id}/"))
    else
      true
    end
  end

end
