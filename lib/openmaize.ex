defmodule Openmaize do
  @moduledoc """
  Openmaize is an authentication library for Elixir.

  It provides the following functionality:

  ## Authentication

    * Openmaize.Authenticate - authenticate the user, using JSON Web Tokens.
    * Openmaize.Login - handle login POST requests.
    * Openmaize.Logout - handle logout requests.

  ## Email confirmation and password resetting

    * Openmaize.ConfirmEmail - verify the token that was sent to the user by email.
    * Openmaize.ResetPassword - verify the token that was sent to the user by email,
    but this time so that the user's password can be reset.

  ## Generators to help you get started

  MORE INFO HERE

  See the relevant module documentation for more details.

  For configuration, see the documentation for Openmaize.Config.

  ## Using with Phoenix

  You can generate an example Authorize module and / or a Confirm module
  by running the command `mix openmaize.gen.phoenixauth`.

  There is an example of Openmaize being used with Phoenix at
  [Openmaize-phoenix](https://github.com/riverrun/openmaize-phoenix).

  """

end
