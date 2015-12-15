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
  three options:
  
    * min_length -- minimum allowable length of the password
    * extra_chars -- check for punctuation characters (including spaces) and digits
    * common -- check to see if the password is too common (easy to guess)

  The default value for `min_length` is 8 characters if `extra_chars` is true,
  but 12 characters if `extra_chars` is false. This is because the password
  should be longer if the character set is restricted to upper and lower case
  letters.

  `extra_chars` and `common` are true by default.

  The documentation for the Comeonin.Password module can give you more
  information about the advantages and disadvantages of checking password
  strength.
  """

  @deprecated """
  This function has been deprecated and will be removed in version 0.10.
  """

  def create_user(user_params, opts \\ []) do
    IO.write :stderr, @deprecated
    Comeonin.create_user(user_params, opts)
  end

end
