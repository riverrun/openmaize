defmodule Openmaize.Confirm do
  @moduledoc """
  Module to handle email confirmation.

  See the documentation for Openmaize.Signup.add_confirm_token for details
  about sending the confirmation token.
  """

  import Ecto.{Query, Changeset}
  import Comeonin.Tools
  alias Openmaize.Config

  @doc """
  Verify the token, update the database and send a confirmation email.

  If the token is valid, `:confirmed`, in the user model, will be set
  to true, and a confirmation email will be sent to the user.

  If the token is not valid, no changes are made to the database, and no
  email will be sent.

  ## Examples

  In the following example, Mailer.confirm_success/1 is a function which
  sends an email to the user, and :confirm is the name of the function
  in your controller which handles confirmation:

      plug Openmaize.Confirm.confirm_user, [confirm_success: &Mailer.confirm_success/1] when action in [:confirm]

  The Mailer.confirm_success function just takes one argument, the email
  address of the user.
  """
  def confirm_user(%Plug.Conn{params: %{email: email, key: key}}, opts) do
    func = Keyword.get(opts, :confirm_success)
    email |> URI.decode_www_form |> check_user(key) |> send_receipt(email, func)
  end

  defp check_user(email, key) do
    from(u in Config.user_model,
         where: u.email == ^email,
         select: u)
    |> Config.repo.one
    |> check_key(key)
  end

  defp check_key(user, key) do
    secure_check(user.confirmation_token, key) and user
  end

  defp send_receipt(false, email, _func) do
    "Confirmation for #{email} failed"
  end
  defp send_receipt(user, email, func) do
    change(user, %{confirmed: true}) |> Config.repo.update!
    func.(email)
  end
end
