defmodule Openmaize.Signup do
  @moduledoc """
  This module handles the signup / creation of a new user.

  By default, bcrypt is used to hash the password, but you can change
  this to pbkdf2_sha512 by setting the `crypto_mod` value in the config
  to `:pbkdf2`.
  """

  @doc """
  This function takes a map with a password in it, removes the password
  and adds an entry for the password hash.
  
  If you set `strength` to true, which is the default, the password
  is checked for strength. The check consists of making sure that
  the password contains at least one digit and one punctuation
  character, and that it is at least 8 characters long. This minimum
  length can be changed by configuring Comeonin. See the documentation
  for Comeonin.Config for more details. If `strength` is set to false, then
  there is no check.

  The documentation for the Comeonin.Password module can give you more
  information about the advantages and disadvantages of checking password
  strength.
  """
  def create_user(user_params, strength \\ true) do
    Comeonin.create_user(user_params, strength)
  end

end
