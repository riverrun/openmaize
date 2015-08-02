defmodule Openmaize.Authorize do
  @moduledoc """
  Plug to verify that users are authorized to access the requested pages
  / resources.

  Authorization is based on user roles, and so you will need a `role` entry
  in your user model.

  This plug can be used as a first stage in authorizing users, and so you
  can call further plugs afterwards to make more fine-grained checks. To
  help these further checks, if authorization is successful, two variables,
  `path` and `match` are stored in the conn.private.openmaize_vars map.
  `path` is the full path of the connection and `match` refers to a matching
  path in the Config.protected map. If no `match` is found, it means that
  the page is unprotected, and extra Openmaize checks are skipped.

  There is one option:

  * redirects
      * if true, which is the default, redirect if authorized or if there is an error

  ## Examples

  Call Authorize without any options:

      Plug Openmaize.Authorize

  Call Authorize without redirects:

      Plug Openmaize.Authorize, redirects: false

  """

  import Openmaize.Authorize.Base

  @behaviour Plug

  def init(opts), do: opts

  @doc """
  Verify that the user is authorized to access the requested page / resource.
  """
  def call(%Plug.Conn{private: private, assigns: assigns} = conn, opts) do
    if Map.get(private, :openmaize_skip) == true do
      conn
    else
      opts = {Keyword.get(opts, :redirects, true)}
      run(conn, opts, Map.get(assigns, :current_user))
    end
  end
  defp run(conn, opts, data) do
    get_match(conn) |> permitted?(data) |> authorized?(conn, opts)
  end

end
