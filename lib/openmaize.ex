defmodule Openmaize do
  @moduledoc """
  Openmaize is a collection of functions which can be used to
  authenticate users in any Plug-based application. It aims to
  be secure, lightweight and well-documented.

  ## Getting started with Openmaize and Phoenix

  The easiest way to get started is to use the openmaize_phx
  installer. First, download and install it:

      mix archive.install https://github.com/riverrun/openmaize/raw/master/installer/archives/openmaize_phx.ez

  Then run the `mix openmaize.phx` command in the main directory
  of the Phoenix app. The following options are available:

    * `--confirm` - add files for email confirmation
    * `--api` - create files for an api

  You can find more information at the
  [Openmaize wiki](https://github.com/riverrun/openmaize/wiki).

  There is also an example of Openmaize being used with Phoenix at
  [Openmaize-phoenix](https://github.com/riverrun/openmaize-phoenix).

  ## Openmaize Plugs

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
