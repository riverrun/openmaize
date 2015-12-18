defmodule Openmaize.Signup do
  @moduledoc """
  """

  import Ecto.Changeset
  import NotQwerty123.PasswordStrength
  alias Openmaize.Config

  def create_user(changeset, params) do
    changeset
    |> cast(params, ~w(password), [])
    |> validate_length(:password, min: 8, max: 80)
    |> put_pass_hash()
  end

  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        strong_pword_put_change(changeset, password)
      _ -> changeset
    end
  end

  defp strong_pword_put_change(changeset, password, opts \\ []) do
    case strong_password?(password, opts) do
      true -> put_change(changeset, :password_hash, Config.get_crypto_mod.hashpwsalt(password))
      message -> add_error(changeset, :password, message)
    end
  end
end
