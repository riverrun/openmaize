defmodule Sanction.Authenticate do
  @moduledoc """
  Module to handle password authentication and the generation
  of tokens.
  """

  import Sanction.Config

  @doc """
  Create a password hash for each new user. This entry should
  be recorded in the database as `password_hash`.
  """
  def create_password_hash(password) do
    crypto_mod.hashpwsalt(password)
  end

  @doc """
  Perform a dummy check for no user.
  """
  def check_user(nil, _) do
    crypto_mod.dummy_checkpw
    nil
  end
  @doc """
  Check the user and user's password.
  """
  def check_user(user, password) do
    case crypto_mod.checkpw(password, user.password_hash) do
      true -> user
      _ -> nil
    end
  end

  def generate_token(user) do
    Map.take(user, [:id])
    |> Map.merge(%{exp: token_expiry_secs})
    |> Joken.encode(Config.secret_key)
  end

  defp token_expiry_secs do
    (:calendar.universal_time
    |> :calendar.datetime_to_gregorian_seconds)
    + token_validity
  end 

end
