defmodule <%= base %>.Auth do

  import Phoenix.Token
  import Plug.Conn

  @max_age 24 * 60 * 60

  def verify_token(%Plug.Conn{req_headers: headers} = conn, _opts) do
    case List.keyfind(headers, "authorization", 0) do
      {_, token} ->
        verify(<%= base %>.Endpoint, "user token", token, max_age: @max_age)
        |> set_current_user(conn)
      nil -> assign(conn, :current_user, nil)
    end
  end

  defp set_current_user({:ok, user_id}, conn) do
    assign(conn, :current_user, user_id)
  end
  defp set_current_user({:error, _reason}, conn) do
    assign(conn, :current_user, nil)
  end
end
