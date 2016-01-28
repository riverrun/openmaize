defmodule Openmaize.Confirm do
  @moduledoc """
  Module to handle email confirmation.

  See the documentation for Openmaize.Signup.add_confirm_token for details
  about producing the confirmation token.
  """

  import Comeonin.Tools
  alias Openmaize.QueryTools

  @doc """
  Verify the token sent by email.

  If the token is valid, `{:ok, user, email}` will be returned.

  If the token is not valid, `{:error, message}` will be returned.

  ## Options

  There is one option:

  * query_function - a custom function to query the database
    * if you are using Ecto, you will probably not need this

  This is a function that you need to provide. See the examples below
  to see how to set this option when calling `user_email`.

  ## Examples

  """
  def user_email(%Plug.Conn{params: %{"email" => email, "key" => key}}, opts \\ []) do
    query_func = Keyword.get(opts, :query_function, &QueryTools.find_user/2)
    email
    |> URI.decode_www_form
    |> query_func.(:email)
    |> check_key(key)
    |> valid_key(email)
  end

  defp check_key(user, key) do
    secure_check(user.confirmation_token, key) and user
  end

  defp valid_key(false, email) do
    {:error, "Confirmation for #{email} failed"}
  end
  defp valid_key(user, email) do
    {:ok, user, email}
  end
end
