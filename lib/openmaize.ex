defmodule Openmaize do
  @moduledoc """
  Openmaize is an authentication / authorization library for Elixir.

  It uses Plug extensively and provides the following plugs:

  * Openmaize.Authenticate
    * authenticates the user
    * sets (adds to the assigns map) the current_user variable
  * Openmaize.AccessControl.authorize
    * check, based on the user's role, to see if the user is authorized to access the page
  * Openmaize.AccessControl.authorize_id
    * check, based on user id, to see if the user is authorized to access the page
  * Openmaize.Login
    * handle login POST request
  * Openmaize.Logout
    * handle logout request

  See the relevant module documentation for more details.

  """

  use Application

  @doc false
  def start(_type, _args) do
    Openmaize.Supervisor.start_link
  end

end
