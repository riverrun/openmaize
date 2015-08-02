defmodule Openmaize.Authorize do
  @moduledoc """
  Plug that performs a basic check that users are authorized to access the
  requested pages / resources.

  Authorization is based on user roles, and so you will need a `role` entry
  in your user model.

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
      run_check(conn, opts, Map.get(assigns, :current_user))
    end
  end
  defp run_check(conn, opts, data) do
    get_match(conn) |> permitted?(data) |> authorized?(conn, opts)
  end

end
