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
    Application.get_env(:openmaize, :crypto_mod, Comeonin.Bcrypt)
  end

  def storage_method do
    Application.get_env(:openmaize, :storage_method, "cookie")
  end

  def secret_key do
    Application.get_env(:openmaize, :secret_key, "you will never guess")
  end

  def login_page do
    Application.get_env(:openmaize, :login_page, "/users/login")
  end

  def token_validity do
    Application.get_env(:openmaize, :token_validity_in_minutes, 24 * 60) * 60
  end
end
