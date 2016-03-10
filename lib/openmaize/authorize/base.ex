defmodule Openmaize.Authorize.Base do
  @moduledoc """
  Base implementation of the authorization module.

  This is used by both the Openmaize.Authorize and Openmaize.AuthorizeId
  modules.

  You can also use it to create your own custom module / plug.

  # MAYBE move this back to the access_control module
  # or maybe remove authorization completely - just give examples
  """

  @doc false
  defmacro __using__(_) do
    quote do
      @behaviour Plug

      import unquote(__MODULE__)

      @doc false
      def init(opts) do
        Keyword.get(opts, :roles, [])
      end

      @doc false
      def call(%Plug.Conn{assigns: %{current_user: current_user}} = conn, opts) do
        full_check(conn, opts, current_user)
      end

      defoverridable [init: 1, call: 2]
    end
  end

  import Plug.Conn

  @doc """
  Check the current user's role is in the list of allowed roles.
  """
  def full_check(_conn, [], _) do
    raise ArgumentError, "You need to set the `roles` option for :authorize"
  end
  def full_check(conn, _, nil), do: nouser_error(conn)
  def full_check(conn, roles, %{role: role}) do
    if role in roles, do: conn, else: nopermit_error(conn, role)
  end

  @doc """
  Check that the id matches the current user's id.
  """
  def id_check(conn, _id, nil), do: nouser_error(conn)
  def id_check(conn, id, current_user) do
    if id == to_string(current_user.id) do
      conn
    else
      nopermit_error(conn, current_user.role)
    end
  end

  defp nouser_error(%Plug.Conn{request_path: path} = conn) do
    message = "You have to be logged in to view #{path}"
    put_private(conn, :openmaize_info, message)
    #resp(conn, 401, Poison.encode!(message)) |> halt()
  end

  defp nopermit_error(%Plug.Conn{request_path: path} = conn, _role) do
    message = %{"error" => "You do not have permission to view #{path}"}
    put_private(conn, :openmaize_info, message)
    #resp(conn, 403, Poison.encode!(message)) |> halt()
  end
end
