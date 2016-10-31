defmodule Openmaize.Authenticate do
  @moduledoc """
  Authenticate the current user, using Plug sessions.

  ## Options

  There are two options:

    * repo - the name of the repo
      * the default is MyApp.Repo - using the name of the project
    * user_model - the name of the user model
      * the default is MyApp.User - using the name of the project

  ## Example using Phoenix

  Add the following line to the pipeline in the `web/router.ex` file:

      plug Openmaize.Authenticate

  """

  import Plug.Conn

  @behaviour Plug

  def init(opts) do
    {Keyword.get(opts, :repo, Openmaize.Utils.default_repo),
    Keyword.get(opts, :user_model, Openmaize.Utils.default_user_model)}
  end

  @doc """
  Authenticate the current user.
  """
  def call(conn, {repo, user_model}) do
    get_session(conn, :user_id) |> get_user(conn, repo, user_model)
  end

  defp get_user(nil, conn, _, _), do: assign(conn, :current_user, nil)
  defp get_user(id, conn, repo, user_model) do
    repo.get(user_model, id) |> set_current_user(conn)
  end

  defp set_current_user(nil, conn), do: assign(conn, :current_user, nil)
  defp set_current_user(user, conn), do: assign(conn, :current_user, user)
end
