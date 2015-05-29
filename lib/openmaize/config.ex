defmodule Openmaize.Config do
  @moduledoc """
  """

  @doc """
  The user model name.
  """
  def user_model do
    Application.get_env(:openmaize, :user_model)
  end

  @doc """
  The repo name.
  """
  def repo do
    Application.get_env(:openmaize, :repo)
  end

  @doc """
  The password hashing and checking algorithm. You can choose between
  bcrypt and pbkdf2_sha512. Bcrypt is the default.

  For more information about these two algorithms, see the documentation
  for Comeonin.
  """
  def get_crypto_mod do
    case crypto_mod do
      :pbkdf2 -> Comeonin.Pbkdf2
      _ -> Comeonin.Bcrypt
    end
  end

  defp crypto_mod do
    Application.get_env(:openmaize, :crypto_mod, :bcrypt)
  end

  @doc """
  The storage method for the token. The default is to store it in
  a cookie which is then sent to the user.

  In the future, there will be support for storing the token in
  sessionStorage, but this is not supported yet.
  """
  def storage_method do
    Application.get_env(:openmaize, :storage_method, "cookie")
  end

  @doc """
  The secret key for use with Joken (which encodes and decodes the
  tokens).
  """
  def secret_key do
    Application.get_env(:openmaize, :secret_key, "you will never guess")
  end

  @doc """
  The number of minutes that you want the token to be valid for.
  """
  def token_validity do
    Application.get_env(:openmaize, :token_validity_in_minutes, 24 * 60) * 60
  end

end
