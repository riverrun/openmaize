defmodule Openmaize do
  @moduledoc """
  Openmaize is an authentication / authorization library for Elixir.

  It uses Plug extensively and provides the following plugs:

  * Openmaize.Authenticate
    * authenticates the user
    * sets (adds to the assigns map) the current_user variable
  * Openmaize.AccessControl.authorize
  * Openmaize.AccessControl.authorize_id
  * Openmaize.Login
  * Openmaize.Logout

  See the relevant module documentation for more details.

  """

  use Application

  @doc false
  def start(_type, _args) do
    Openmaize.Supervisor.start_link
  end

end
