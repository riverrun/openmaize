defmodule Openmaize.Authorize.Base do
  @moduledoc """
  Base implementation of the authorization module.

  This is used by both the Openmaize.Authorize and Openmaize.AuthorizeId
  modules.
  """

  @doc false
  defmacro __using__(_) do
    quote do
      @behaviour Plug

      import unquote(__MODULE__)

      @doc false
      def init(opts) do
        {Keyword.get(opts, :roles, []), Keyword.get(opts, :redirects, true)}
      end

      @doc false
      def call(%Plug.Conn{assigns: %{current_user: current_user}} = conn, opts) do
        full_check(conn, opts, current_user)
      end

      defoverridable [init: 1, call: 2]
    end
  end

  import Plug.Conn
  import Openmaize.Redirect
  alias Openmaize.Config

  @doc """
  Check the current user's role is in the list of allowed roles.
  """
  def full_check(_conn, {[], _}, _) do
    raise ArgumentError, "You need to set the `roles` option for :authorize"
  end
  def full_check(conn, {_, redirects}, nil), do: nouser_error(conn, redirects)
  def full_check(conn, {roles, redirects}, %{role: role}) do
    if role in roles, do: conn, else: nopermit_error(conn, role, redirects)
  end

  @doc """
  Check that the id matches the current user's id.
  """
  def id_check(conn, redirects, _id, nil), do: nouser_error(conn, redirects)
  def id_check(conn, redirects, id, current_user) do
    if id == to_string(current_user.id) do
      conn
    else
      nopermit_error(conn, current_user.role, redirects)
    end
  end

  defp nouser_error(%Plug.Conn{request_path: path} = conn, true) do
    message = %{"error" => "You have to be logged in to view #{path}"}
    redirect_to(conn, "#{Config.redirect_pages["login"]}", message)
  end
  defp nouser_error(%Plug.Conn{request_path: path} = conn, false) do
    message = "You have to be logged in to view #{path}"
    send_resp(conn, 401, Poison.encode!(message)) |> halt()
  end

  defp nopermit_error(%Plug.Conn{request_path: path} = conn, role, true) do
    message = %{"error" => "You do not have permission to view #{path}"}
    redirect_to(conn, "#{Config.redirect_pages[role]}", message)
  end
  defp nopermit_error(%Plug.Conn{request_path: path} = conn, _role, false) do
    message = %{"error" => "You do not have permission to view #{path}"}
    send_resp(conn, 403, Poison.encode!(message)) |> halt()
  end
end
