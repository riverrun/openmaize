defmodule Openmaize.LoginTools do
  @moduledoc """
  Query the database and check the user's password.

  The `check_user` function is called by Openmaize.Login, but
  this can be replaced with a custom function.
  """

  import Ecto.Query
  import Openmaize.Config

  @doc """
  Find the user in the database and check the password.
  """
  def check_user(uniq, unique, user_params) do
    %{^unique => user, "password" => password} = user_params
    from(u in user_model,
         where: field(u, ^uniq) == ^user,
         select: u)
    |> repo.one
    |> check_pass(password)
  end

  @doc """
  Check the password with the password hash stored in the database.
  """
  def check_pass(nil, _), do: get_crypto_mod.dummy_checkpw
  def check_pass(%{confirmed: false}, _),
    do: {:error, "You have to confirm your email address before continuing."}
  def check_pass(user, password) do
    get_crypto_mod.checkpw(password, user.password_hash) and user
  end
end
