defmodule Openmaize.Config do
  @moduledoc """
  """

  def user_model do
    Application.get_env(:openmaize, :user_model)
  end

  def repo do
    Application.get_env(:openmaize, :repo)
  end

  def crypto_mod do
    Application.get_env(:openmaize, :crypto_mod, :bcrypt)
  end

  def storage_method do
    Application.get_env(:openmaize, :storage_method, "cookie")
  end

  def secret_key do
    Application.get_env(:openmaize, :secret_key, "you will never guess")
  end

  def token_validity do
    Application.get_env(:openmaize, :token_validity_in_minutes, 24 * 60) * 60
  end

  def get_crypto_mod do
    case crypto_mod do
      :pbkdf2 -> Comeonin.Pbkdf2
      _ -> Comeonin.Bcrypt
    end
  end
end
