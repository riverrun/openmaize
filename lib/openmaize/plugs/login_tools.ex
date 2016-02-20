defmodule Openmaize.LoginTools do
  @moduledoc """
  Tools that can be used with the Login module.
  """

  @doc """
  Check that the data is a valid email.
  """
  def email_username(data) do
    Regex.match?(~r/^.+@.+\..+$/, data) and :email || :username
  end

  @doc """
  Check that the data is a valid phone number.
  """
  def phone_username(data) do
    Regex.match?(~r/^[0-9]+$/, data) and :phone || :username
  end
end
