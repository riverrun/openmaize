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
  alias Openmaize.{Config, QueryTools, Signup}

  @behaviour Plug

  def init(opts) do
    {Keyword.get(opts, :key_expires_after, 1440),
     Keyword.get(opts, :mail_function),
     Keyword.get(opts, :redirects, true),
     Keyword.get(opts, :query_function, &QueryTools.find_user/2)}
  end

  @doc """
  Validate a link which was sent to a user by email.

  ## Options

  There are four options:

  * key_expires_after - the length of time, in minutes, that the token should be valid for
  * mail_function - the mailing function
  * redirects - if Openmaize should handle redirects
  * query_function - function to query the database

  """
  def call(%Plug.Conn{params: %{"email" => email, "key" => key, "password" => password}} = conn, opts) do
    check_user_key(conn, email, key, password, opts)
  end
  def call(%Plug.Conn{params: %{"email" => email, "key" => key}} = conn, opts) do
    check_user_key(conn, email, key, :nopassword, opts)
  end
  def call(conn, {_, _, redirects, _}) do
    put_message(conn, "logout", %{"error" => "Invalid link"}, redirects)
  end

  defp check_user_key(conn, email, key, password, {key_expiry, mail_func, redirects, query_func})
  when byte_size(key) == 32 do
    email
    |> URI.decode_www_form
    |> query_func.(:email)
    |> check_key(key, key_expiry * 60, password)
    |> finalize(conn, email, mail_func, redirects)
  end

  defp check_key(user, key, valid_secs, :nopassword) do
    check_time(user.confirmation_sent_at, valid_secs) and
    secure_check(user.confirmation_token, key) and
    change(user, %{confirmed_at: Ecto.DateTime.utc}) |> Config.repo.update
  end
  defp check_key(user, key, valid_secs, password) do
    check_time(user.reset_sent_at, valid_secs) and
    secure_check(user.reset_token, key) and
    Signup.add_password_hash(%{"password" => password})
  end

  defp check_time(sent_at, valid_secs) do
    (sent_at |> Ecto.DateTime.to_erl
     |> :calendar.datetime_to_gregorian_seconds) + valid_secs >
    (:calendar.universal_time |> :calendar.datetime_to_gregorian_seconds)
  end

  defp finalize({:ok, _user}, conn, email, mail_func, redirects) do
    mail_func && mail_func.(email)
    put_message(conn, %{"info" => "Account successfully confirmed"}, redirects)
  end
  defp finalize(false, conn, email, _, redirects) do
    put_message(conn, "logout", %{"error" => "Confirmation for #{email} failed"}, redirects)
  end
end
