defmodule Openmaize.LoginTools do
  @moduledoc """
  Tools that can be used with the Login module.

  These functions can be used with the Openmaize.Login plug as the
  unique_id. They can also just serve as examples of how to write
  such a function.
  """

  @doc """
  Check to see if user input is an email or username, and return the user
  data and password.

  For this function to work, the login form needs to contain an "email" and
  "password" in the `user` parameters.
  """
  def email_username(%{"email" => email, "password" => password}) do
    {Regex.match?(~r/^.+@.+\..+$/, email) and :email || :username, email, password}
  end

  @doc """
  Check to see if user input is a phone number or username, and return the user
  data and password.

  For this function to work, the login form needs to contain a "phone" and
  "password" in the `user` parameters.
  """
  def phone_username(%{"phone" => phone, "password" => password}) do
    {Regex.match?(~r/^[0-9]+$/, phone) and :phone || :username, phone, password}
  end
end
