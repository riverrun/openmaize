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

  ## Various helper functions

  In the Openmaize.DB module:

  * add_password_hash - take an Ecto changeset, hash the password and add the
  password hash to the changeset.
  * add_confirm_token - add a confirmation token to the changeset.
  * add_reset_token - add a reset token to the changeset.

  See the relevant module documentation for more details.

  For configuration, see the documentation for Openmaize.Config.

  There is an example of Openmaize being used with Phoenix at
  [Openmaize-phoenix](https://github.com/riverrun/openmaize-phoenix).

  """

  use Application

  @doc false
  def start(_type, _args) do
    Openmaize.Supervisor.start_link
  end

  @doc """
  Restart the keymanager child process without keeping state.

  This can be used to remove the old keys and generate new ones.
  After being stopped, the keymanager will be restarted and new keys
  will be created.
  """
  def restart_keymanager do
    Process.whereis(Openmaize.KeyManager) |> Process.exit(:kill)
  end
end
