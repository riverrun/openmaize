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
  * Openmaize.Authorize
      * checks to see if the user is authorized to access the page / resource
      * authorization is based on user role

  There is also the following plug, which can be used to perform an extra
  authorization check based on user id:

  * Openmaize.Authorize.IdCheck
      * checks to see if the user, based on id, is authorized to access the page / resource

  See the relevant module documentation for more details.

  """

  use Application

  @doc false
  def start(_type, _args) do
    Openmaize.Supervisor.start_link
  end

end
