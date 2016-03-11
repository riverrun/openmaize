defmodule <%= base %>.Auth do
  import Plug.Conn
  import Phoenix.Controller

  @doc """
  """
  def authorize_action(%Plug.Conn{assigns: %{current_user: nil}} = conn, _, _) do
    unauthenticated conn
  end
  def authorize_action(%Plug.Conn{assigns: %{current_user: current_user},
                                  params: params} = conn, roles, module) do
    if current_user.role in roles do
      apply(module, action_name(conn), [conn, params, current_user])
    else
      unauthorized conn, current_user
    end
  end

  @doc """
  """
  def unauthenticated(conn) do
    render(conn, <%= base %>.ErrorView, "401.json", [])
  end

  @doc """
  """
  def unauthorized(conn, _current_user) do
    render(conn, <%= base %>.ErrorView, "403.json", [])
  end

  @doc """
  """
  def id_check(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts) do
    unauthenticated conn
  end
  def id_check(%Plug.Conn{params: %{"id" => id},
              assigns: %{current_user: %{id: current_id} = current_user}} = conn, _opts) do
    id == to_string(current_id) and conn || unauthorized conn, current_user
  end

  @doc """
  """
  def handle_login(%Plug.Conn{private: %{openmaize_error: _message}} = conn, _params) do
    unauthenticated conn
  end
  def handle_login(%Plug.Conn{private:
                            %{openmaize_user: %{id: id}}} = conn, _params) do
    user = Repo.get(User, id) # do we need to call the db
    render(conn, "show.json", user: user) # send the token
  end

  @doc """
  """
  def handle_confirm(%Plug.Conn{private: %{openmaize_error: _message}} = conn, _params) do
    unauthenticated conn
  end
  def handle_confirm(%Plug.Conn{private: %{openmaize_info: _message}} = conn, _params) do
    send_resp conn, 200, ""
  end

  @doc """
  """
  def handle_reset(%Plug.Conn{private: %{openmaize_error: _message}} = conn, _params) do
    unauthenticated conn
  end
  def handle_reset(%Plug.Conn{private: %{openmaize_info: _message}} = conn, _params) do
    send_resp conn, 200, ""
  end

end
