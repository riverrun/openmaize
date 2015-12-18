defmodule Openmaize.Signup do
  @moduledoc """
  """

  import Ecto.Changeset
  import NotQwerty123.PasswordStrength
  alias Openmaize.Config

  def login_user(changeset, params) do
    changeset
    |> cast(params, ~w(password), [])
    |> validate_length(:password, min: 8, max: 80)
    |> put_pass_hash()
  end

  def put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        #put_change(changeset, :password_hash, Config.get_crypto_mod.hashpwsalt(password))
        check_pword_put_change(changeset, password)
      _ -> changeset
    end
  end

  defp check_pword_put_change(changeset, password, opts \\ []) do
    case strong_password?(password, opts) do
      true -> put_change(changeset, :password_hash, Config.get_crypto_mod.hashpwsalt(password))
      message -> add_error(changeset, :password, message)
    end
  end
end
