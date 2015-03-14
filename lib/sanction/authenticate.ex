defmodule Sanction.Authenticate do
  @moduledoc """
  """

  import Comeonin.Pbkdf2

  def create_user(username, password) do
    {username, hashpwsalt(password)}
  end

  def check_user(nil, _), do: dummy_checkpw
  def check_user(user, password) do
    checkpw(password, user.password_hash)
  end

end
