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

  There is one option:

  * query_function - a custom function to query the database
    * if you are using Ecto, you will probably not need this

  ## Examples

  The example below shows a function for the `confirm` route, which
  needs to be set in the `web/router.ex` file, in a controller for
  a Phoenix app.

  The `Mailer.receipt_confirm` function is a function that you need to
  write to send an email stating that confirmation was successful.

      def confirm(conn, params) do
        case Openmaize.Confirm.user_email(conn) do
          {:ok, user, email} ->
            Mailer.receipt_confirm(email)
            conn
            |> put_flash(:info, "You have successfully confirmed your account.")
            |> redirect(to: login_path(conn, :login))
          {:error, message} ->
            conn
            |> put_flash(:error, "Something went wrong with the confirmation of your account.")
            |> redirect(to: page_path(conn, :index))
        end
      end

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
    put_change(user, :confirmed, true) |> Config.repo.update! # maybe use change instead of put_change
    {:ok, user, email}
  end
end
