defmodule Openmaize.Signup do
  @moduledoc """
  """

  alias Openmaize.Config

  @doc """
  Create a password hash for each new user. This entry should
  be recorded in the database as `password_hash`.
  """
  def create_password_hash(password) do
    Config.crypto.hashpwsalt(password)
  end

end
