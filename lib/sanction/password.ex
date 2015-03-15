defmodule Sanction.Password do
  @moduledoc """
  Module to handle password-related functionality.
  """

  alias Comeonin.Pbkdf2

  @doc """
  Create a password hash for each new user. This entry should
  be recorded in the database as `password_hash`.
  """
  def create_password_hash(password) do
    Pbkdf2.hashpwsalt(password)
  end

  @doc """
  Perform a dummy check for no user.
  """
  def check_user(nil, _) do
    Pbkdf2.dummy_checkpw
    nil
  end
  @doc """
  Check the user and user's password.
  """
  def check_user(user, password) do
    case Pbkdf2.checkpw(password, user.password_hash) do
      true -> user
      _ -> nil
    end
  end

end
