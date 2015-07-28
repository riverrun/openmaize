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
  
  Before hashing the password, it is checked for strength. This check has
  two options: min_length and extra_chars. extra_chars checks that the
  password contains at least one digit and one punctuation character,
  and is true by default. min_length refers to the minimum length of
  the password and defaults to 8 characters if extra_chars is true, but
  12 characters if extra_chars is false.

  The documentation for the Comeonin.Password module can give you more
  information about the advantages and disadvantages of checking password
  strength.
  """
  def create_user(user_params, opts \\ []) do
    Comeonin.create_user(user_params, opts)
  end

end
