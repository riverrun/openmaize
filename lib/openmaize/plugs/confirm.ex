defmodule Openmaize.Confirm do
  @moduledoc """
  Module to help with email confirmation.

  This module can be used for account confirmation by email or for
  resetting a password.

  See the documentation for `add_confirm_token` and `add_reset_token` in
  the Openmaize.Signup module for details about creating the token.
  """

  import Comeonin.Tools
  import Ecto.Changeset
  import Openmaize.Report
  alias Openmaize.{Config, QueryTools}

  @behaviour Plug

  def init(opts) do
    {Keyword.get(opts, :key_expires_after, 1440),
     Keyword.get(opts, :mail_function),
     Keyword.get(opts, :redirects, true),
     Keyword.get(opts, :confirm_type, :account),
     Keyword.get(opts, :query_function, &QueryTools.find_user/2)}
  end

  @doc """
  Validate a link which was sent to a user by email.

  ## Options

  There are five options:

  * key_expires_after - the length of time, in minutes, that the token should be valid for
  * mail_function - the mailing function
  * redirects - if Openmaize should handle redirects
  * confirm_type - account confirmation or password reset
  * query_function - function to query the database

  """
  def call(%Plug.Conn{params: %{"email" => email, "key" => key}} = conn,
           {key_expiry, mail_func, redirects, confirm_type, query_func})
  when byte_size(key) == 32 do
    email
    |> URI.decode_www_form
    |> query_func.(:email)
    |> check_key(confirm_type, key_expiry * 60, key)
    |> finalize(conn, confirm_type, email, mail_func, redirects)
  end
  def call(conn, {_, _, redirects, _, _}) do
    put_message(conn, "logout", %{"error" => "Invalid link"}, redirects)
  end

  defp check_key(user, :account, valid_secs, key) do
    check_time(user.confirmation_sent_at, valid_secs) and
    secure_check(user.confirmation_token, key) and
    change(user, %{confirmed_at: Ecto.DateTime.utc}) |> Config.repo.update
  end
  defp check_key(user, :reset, valid_secs, key) do
    check_time(user.reset_sent_at, valid_secs) and
    secure_check(user.reset_token, key) and {:ok, user}
  end

  defp check_time(sent_at, valid_secs) do
    (sent_at |> Ecto.DateTime.to_erl
     |> :calendar.datetime_to_gregorian_seconds) + valid_secs >
    (:calendar.universal_time |> :calendar.datetime_to_gregorian_seconds)
  end

  defp finalize({:ok, _user}, conn, :account, email, mail_func, redirects) do
    mail_func && mail_func.(email)
    put_message(conn, %{"info" => "Account successfully confirmed"}, redirects)
  end
  defp finalize({:ok, _user}, conn, :reset, _, _, _), do: conn
  defp finalize(false, conn, _, email, _, redirects) do
    put_message(conn, "logout", %{"error" => "Confirmation for #{email} failed"}, redirects)
  end
end
