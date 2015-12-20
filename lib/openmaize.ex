defmodule Openmaize do
  @moduledoc """
  Openmaize is an authentication / authorization library for Elixir.

  It uses Plug extensively and provides the following main plugs:

  * Openmaize.LoginoutCheck
      * checks the path to see if it is for the login or logout page
      * handles login or logout if necessary
  * Openmaize.Authenticate
      * authenticates the user
      * sets (adds to the assigns map) the current_user variable

  There are also plugs that can be used for authorization in the
  Openmaize.AccessControl module.

  See the relevant module documentation for more details.

  """

  use Application

  @doc false
  def start(_type, _args) do
    Openmaize.Supervisor.start_link
  end

end
