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

      plug Openmaize.Authorize

  Call Authorize without redirects:

      plug Openmaize.Authorize, redirects: false

  """

  import Openmaize.Authorize.Base

  @behaviour Plug

  def init(opts), do: opts

  @doc """
  Verify that the user is authorized to access the requested page / resource.
  """
  def call(%Plug.Conn{private: %{openmaize_skip: true}} = conn, _opts), do: conn
  def call(%Plug.Conn{assigns: assigns} = conn, opts) do
    opts = {Keyword.get(opts, :redirects, true)}
    full_check(conn, opts, Map.get(assigns, :current_user))
  end

end
