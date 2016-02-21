defmodule Openmaize.LoginTools do
  @moduledoc """
  Tools that can be used with the Login module.

  These functions can be used with the Openmaize.Login plug as the
  unique_id. They can also just serve as examples of how to write
  such a function.
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
