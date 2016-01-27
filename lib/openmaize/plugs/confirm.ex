defmodule Openmaize.Confirm do
  @moduledoc """
  Module to handle email confirmation.

  See the documentation for Openmaize.Signup.add_confirm_token for details
  about sending the confirmation token.
  """

  import Ecto.Changeset
  import Comeonin.Tools
  import Plug.Conn
  alias Openmaize.{Config, QueryTools}

  @doc """
  Verify the token, update the database and send a confirmation email.

  If the token is valid, `:confirmed`, in the user model, will be set
  to true, and a confirmation email will be sent to the user.

  If the token is not valid, no changes are made to the database, and no
  email will be sent.

  ## Options

  There are two options:

  * valid_email - a function to send a confirmation email to the user
  * query_function - a custom function to query the database
    * if you are using Ecto, you will probably not need this

  This is a function that you need to provide. See the examples below
  to see how to set this option when calling `user_email`.

  ## Examples

  In the following example, Mailer.receipt_confirm/1 is a function which
  sends an email to the user, and :confirm is the name of the function
  in your controller which handles confirmation:

      import Openmaize.Confirm
      plug :user_email, [valid_email: &Mailer.receipt_confirm/1] when action in [:confirm]

  The Mailer.receipt_confirm function just takes one argument, the email
  address of the user.
  """
  def user_email(%Plug.Conn{params: %{"email" => email, "key" => key}} = conn, opts) do
    {query_func, send_func} = {Keyword.get(opts, :query_function, &QueryTools.find_user/2),
                               Keyword.get(opts, :valid_email)}
    email
    |> URI.decode_www_form
    |> query_func.(:email)
    |> check_key(key)
    |> send_receipt(email, send_func)
    halt(conn)
  end

  defp check_key(user, key) do
    secure_check(user.confirmation_token, key) and user
  end

  defp send_receipt(false, email, _send_func) do
    "Confirmation for #{email} failed"
  end
  defp send_receipt(user, email, send_func) do
    change(user, %{confirmed: true}) |> Config.repo.update!
    send_func.(email)
  end
end
