defmodule Sanction.Signup do
  @moduledoc """
  """

  alias Comeonin.Pbkdf2

  @doc """
  Create a password hash for each new user. This entry should
  be recorded in the database as `password_hash`.
  """
  def create_password_hash(password) do
    Pbkdf2.hashpwsalt(password)
  end

end
