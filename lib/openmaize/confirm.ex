defmodule Openmaize.Confirm do
  @moduledoc """
  Module to help with email confirmation.

  See the documentation for Openmaize.Signup.add_confirm_token for details
  about creating the confirmation token.
  """

  import Comeonin.Tools
  import Ecto.Changeset
  alias Openmaize.{Config, QueryTools}

  @doc """
  Verify the token sent by email.

  If the token is valid, `{:ok, user, email}` will be returned, and
  if the token is not valid, `{:error, message}` will be returned.

  ## Options

  There are two options:

  * confirmation_validity - the length of time that a confirmation token is valid
    * the value is in minutes
    * the default is 1440 minutes (1 day)
  * query_function - a custom function to query the database
    * if you are using Ecto, you will probably not need this

  ## Examples

  The example below shows a function for the `confirm` route, which
  needs to be set in the `web/router.ex` file, in a controller for
  a Phoenix app.

  The `Mailer.receipt_confirm` function is a function that you need to
  write to send an email stating that confirmation was successful.

      def confirm(conn, _params) do
        case Openmaize.Confirm.user_email(conn) do
          {:ok, _user, email} ->
            Mailer.receipt_confirm(email)
            conn
            |> put_flash(:info, "You have successfully confirmed your account.")
            |> redirect(to: login_path(conn, :login))
          {:error, message} ->
            conn
            |> put_flash(:error, message)
            |> redirect(to: page_path(conn, :index))
        end
      end

  To set a 2-hour time limit for the account to be confirmed:

      Openmaize.Confirm.user_email(conn, confirmation_validity: 120)

  """
  def user_email(conn, opts \\ [])
  def user_email(%Plug.Conn{params: %{"email" => email, "key" => key}}, opts) do
    {confirm_validity, query_func} = {Keyword.get(opts, :confirmation_validity, 1440),
                                      Keyword.get(opts, :query_function, &QueryTools.find_user/2)}
    email
    |> URI.decode_www_form
    |> query_func.(:email)
    |> check_key(confirm_validity * 60, key)
    |> valid_key(email)
  end
  def user_email(_, _), do: {:error, "Invalid link"}

  defp check_time(sent_at, validity_secs) do
    (sent_at |> Ecto.DateTime.to_erl
     |> :calendar.datetime_to_gregorian_seconds) + validity_secs >
    (:calendar.universal_time |> :calendar.datetime_to_gregorian_seconds)
  end

  defp check_key(user, validity_secs, key) do
    check_time(user.confirmation_sent_at, validity_secs) and
    secure_check(user.confirmation_token, key) and user
  end

  defp valid_key(false, email) do
    {:error, "Confirmation for #{email} failed"}
  end
  defp valid_key(user, email) do
    {:ok, user} = change(user, %{confirmed: true}) |> Config.repo.update
    {:ok, user, email}
  end
end
