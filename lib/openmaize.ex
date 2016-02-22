defmodule Openmaize do
  @moduledoc """
  Openmaize is an authentication / authorization library for Elixir.

  It provides the following functionality:

  ## Authentication

  * Openmaize.Authenticate - plug to authenticate users, using Json Web Tokens.
  * Openmaize.Login - plug to handle login POST requests.
  * Openmaize.Logout - plug to handle logout requests.

  ## Authorization

  In the Openmaize.AccessControl module:

  * authorize - verify that the user, based on user role, is authorized to
  access the requested page.
  * authorize_id - verify that the user, based on the user id, is authorized to
  access the requested page.

  ## User creation helper functions

  In the Openmaize.DB module:

  * add_password_hash - take an Ecto changeset, hash the password and add the
  password hash to the changeset.
  * add_confirm_token - add a confirmation token to the changeset.
  * gen_token_link - generate a confirmation token and a link to be used in
  the confirmation url that is sent to the user.

  In the Openmaize.Confirm module:

  * confirm_email - verify the token that was sent to the user by email.
  * reset_password - like `confirm_email`, verify the token that was sent
  to the user by email, but this time so that the user's password can be reset.

  See the relevant module documentation for more details.

  For configuration, see the documentation for Openmaize.Config.

  There is an example of Openmaize being used with Phoenix at
  [Openmaize-phoenix](https://github.com/riverrun/openmaize-phoenix).

  """

  use Application

  @doc false
  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(Openmaize.Keymanager, [])
    ]

    opts = [strategy: :one_for_one, name: Openmaize.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc """
  Stop the keymanager child process without keeping state.

  This can be used to remove the old keys and generate new ones.
  After being stopped, the keymanager will be restarted and new keys
  will be created.
  """
  def stop_keymanager do
    Process.whereis(Openmaize.Keymanager) |> Process.exit(:kill)
  end
end
