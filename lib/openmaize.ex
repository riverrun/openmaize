defmodule Openmaize do
  @moduledoc """
  Openmaize is an authentication library for Plug-based applications in Elixir.

  Before you use Openmaize, you need to make sure that you have a module
  that implements the Openmaize.Database behaviour. If you are using Ecto,
  you can generate the necessary files by running the following command:

      mix openmaize.gen.ectodb

  To generate modules to handle authorization, and optionally email confirmation,
  run the following command:

      mix openmaize.gen.phoenixauth

  You then need to configure Openmaize. For more information, see the documentation
  for the Openmaize.Config module.

  ## Migrating from Devise

  Follow the above instructions for generating database and authorization
  modules, and then add the following lines to the config file:

      config :openmaize,
        hash_name: :encrypted_password

  Some of the functions in the Authorize module depend on a `role` being
  set for each user. If you are not using roles, you will need to edit
  these functions before use.

  ## Openmaize plugs

    * Authentication
      * Openmaize.Authenticate - authenticate the user, using sessions.
      * Openmaize.Login - handle login POST requests.
      * Openmaize.OnetimePass - plug to handle one-time password POST requests.
      * Openmaize.Remember - plug to check for a `remember me` cookie.
    * Email confirmation and password resetting
      * Openmaize.ConfirmEmail - verify the token that was sent to the user by email.
      * Openmaize.ResetPassword - verify the token that was sent to the user by email,
      but this time so that the user's password can be reset.

  See the relevant module documentation for more details.

  For configuration, see the documentation for Openmaize.Config.

  ## Using with Phoenix

  There is an example of Openmaize being used with Phoenix at
  [Openmaize-phoenix](https://github.com/riverrun/openmaize-phoenix).

  """

end
