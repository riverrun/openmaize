defmodule <%= base %>.SessionController do
  use <%= base %>.Web, :controller

  plug Openmaize.Login when action in [:create]
  #plug Openmaize.Login, [unique_id: :email] when action in [:create]

  def create(%Plug.Conn{private: %{openmaize_error: _message}} = conn, _params) do
    put_status(conn, :unauthorized)
    |> render(TodoApp.AuthView, "401.json", [])
  end
  def create(%Plug.Conn{private: %{openmaize_user: user}} = conn, _params) do
    token = Phoenix.Token.sign(TodoApp.Endpoint, "user token", user.id)
    render(conn, TodoApp.SessionView, "info.json", %{info: token})
  end
end
