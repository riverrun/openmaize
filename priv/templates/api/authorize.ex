defmodule <%= base %>.Authorize do

  import Plug.Conn
  import Phoenix.Controller

  @doc """
  Custom action that can be used to override the `action` function in any
  Phoenix controller.

  ## Examples

  First, import this module in the controller, and then add the following line:

      def action(conn, _), do: authorize_action conn, ["admin", "user"], __MODULE__

  This command will only allow connections for users with the "admin" and "user"
  roles.

  You will also need to change the other functions in the controller to accept
  a third argument, which is the current user. For example, change:
  `def index(conn, params) do` to: `def index(conn, params, user) do`
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
  Send an unauthenticated user an error message.
  """
  def unauthenticated(conn) do
    render(conn, <%= base %>.ErrorView, "401.json", [])
  end

  @doc """
  Send an unauthorized user an error message.
  """
  def unauthorized(conn, _current_user) do
    render(conn, <%= base %>.ErrorView, "403.json", [])
  end

  @doc """
  Check, based on role, that the user is authorized to access this resource.

  ## Examples

  First, import this module, and then add the following line to the controller:

      plug :role_check, [roles: "admin", "user"] when action in [:show, :edit]

  This command will check the user's role for the `show` and `edit` routes.
  """
  def role_check(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts) do
    unauthenticated conn
  end
  def role_check(%Plug.Conn{assigns: %{current_user: current_user}} = conn, opts) do
    roles = Keyword.get(opts, :roles, [])
    current_user.role in roles and conn || unauthorized conn, current_user
  end

  @doc """
  Check, based on user id, that the user is authorized to access this resource.
  """
  def id_check(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts) do
    unauthenticated conn
  end
  def id_check(%Plug.Conn{params: %{"id" => id},
              assigns: %{current_user: %{id: current_id} = current_user}} = conn, _opts) do
    id == to_string(current_id) and conn || unauthorized conn, current_user
  end

  @doc """
  Login and send the JSON Web Token to the user.

  If the login is not successful, the user will be sent an error message.

  ## Examples

  Add the following line to the controller which handles login:

      plug Openmaize.Login, [storage: nil] when action in [:login_user]

  and then call `handle_login` from the `login_user` function:

      def login_user(conn, params), do: handle_login(conn, params)

  See the documentation for Openmaize.Login for all the login options.
  """
  def handle_login(%Plug.Conn{private: %{openmaize_error: _message}} = conn, _params) do
    unauthenticated conn
  end
  def handle_login(%Plug.Conn{private: %{openmaize_user: _user}} = conn, _params) do
    send_resp conn
  end

  @doc """
  Logout and send the user a message.

  ## Examples

  Add the following line to the controller which handles logout:

      plug Openmaize.Logout when action in [:logout]

  and then call `handle_logout` from the `logout` function in the
  controller.
  """
  def handle_logout(%Plug.Conn{private: %{openmaize_info: message}} = conn, _params) do
    render(conn, <%= base %>.UserView, "info.json", %{info: message})
  end
end
