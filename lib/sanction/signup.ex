defmodule Sanction.Signup do
  @moduledoc """
  """

  import Sanction.Config

  @doc """
  Create a password hash for each new user. This entry should
  be recorded in the database as `password_hash`.
  """
  def create_password_hash(password) do
    crypto_mod.hashpwsalt(password)
  end

end
