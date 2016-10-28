defmodule Openmaize do
  @moduledoc """
  Openmaize is an authentication library for Plug-based applications in Elixir.

  If you are using Phoenix, the easiest way to get started is to run
  the following command (add the `--confirm` option to add files
  for email confirmation):

      mix openmaize.gen.phoenixauth

  You then need to configure Openmaize. For more information, see the
  documentation for the Openmaize.Config module.

  There is an example of Openmaize being used with Phoenix at
  [Openmaize-phoenix](https://github.com/riverrun/openmaize-phoenix).

  ## Migrating from Devise

  Follow the above instructions for generating authorization modules,
  and then add the following lines to the config file:

      config :openmaize,
        hash_name: :encrypted_password

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

  """

end
