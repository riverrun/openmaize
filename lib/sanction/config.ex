defmodule Sanction.Config do
  @moduledoc """
  """

  def crypto_mod do
    Application.get_env(:sanction, :crypto_mod, Comeonin.Pbkdf2)
  end

  def secret_key do
    Application.get_env(:sanction, :secret_key, :crypto.rand_bytes(24))
  end

  def token_validity do
    Application.get_env(:sanction, :token_validity_in_minutes, 24 * 60) * 60
  end
end
