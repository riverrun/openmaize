defmodule Openmaize.LoginoutCheck do
  @moduledoc """
  """

  import Plug.Conn
  alias Openmaize.Login
  alias Openmaize.Logout

  @behaviour Plug

  def init(opts), do: opts

  def call(%{path_info: path_info} = conn, opts) do
    opts = {Keyword.get(opts, :redirects), Keyword.get(opts, :check)}
    case Enum.at(path_info, -1) do
      "login" -> handle_login(conn, opts)
      "logout" -> handle_logout(conn, opts)
      _ -> conn
    end
  end

  defp handle_login(%{method: "POST"} = conn, opts), do: Login.call(conn, opts)
  defp handle_login(conn, _opts), do: assign(conn, :current_user, nil)

  defp handle_logout(conn, opts), do: assign(conn, :current_user, nil) |> Logout.call(opts)

end
