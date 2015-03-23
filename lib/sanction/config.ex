defmodule Sanction.Config do
  @moduledoc """
  """

  def user_model do
    Application.get_env(:sanction, :user_model)
  end

  def repo do
    Application.get_env(:sanction, :repo)
  end

  def crypto_mod do
    Application.get_env(:sanction, :crypto_mod, Comeonin.Pbkdf2)
  end

  def secret_key do
    Application.get_env(:sanction, :secret_key, "you should change this")
  end

  def login_page do
    Application.get_env(:sanction, :login_page, "/users/login")
  end

  def token_validity do
    Application.get_env(:sanction, :token_validity_in_minutes, 24 * 60) * 60
  end
end
