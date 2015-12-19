defmodule Openmaize.Signup do
  @moduledoc """
  """

  import Ecto.Changeset
  alias Openmaize.Config

  if Code.ensure_loaded?(NotQwerty123) do
    defp add_pass_changeset(changeset, password, opts) do
      case NotQwerty123.PasswordStrength.strong_password?(password, opts) do
        true -> put_change(changeset, :password_hash, Config.get_crypto_mod.hashpwsalt(password))
        message -> add_error(changeset, :password, message) # add error to phoenix_flash?
      end
    end
  else
    defp add_pass_changeset(changeset, password, opts) do
      put_change(changeset, :password_hash, Config.get_crypto_mod.hashpwsalt(password))
    end
  end

  @doc """
  """
  def create_user(changeset, params, opts \\ []) do
    {min_len, max_len} = {Keyword.get(opts, :min_len, 8), Keyword.get(opts, :max_len, 80)}
    changeset
    |> cast(params, ~w(password), [])
    |> validate_length(:password, min: min_len, max: max_len)
    |> put_pass_hash(opts)
  end

  defp put_pass_hash(changeset, opts) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        add_pass_changeset(changeset, password, opts)
      _ -> changeset
    end
  end

end
