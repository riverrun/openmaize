defmodule Openmaize.Confirm do
  @moduledoc """
  Module to help with email confirmation.

  See the documentation for Openmaize.Signup.add_confirm_token for details
  about creating the confirmation token.
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
  """
  def call(%Plug.Conn{params: %{"email" => email, "key" => key}} = conn,
           {key_expiry, mail_func, redirects, confirm_type, query_func})
  when byte_size(key) == 32 do
    email
    |> URI.decode_www_form
    |> query_func.(:email)
    |> check_key(confirm_type, key_expiry * 60, key)
    |> complete(conn, email, mail_func, redirects)
  end
  def call(conn, {_, _, redirects, _, _}), do: handle_error(conn, "Invalid link", redirects)

  defp check_key(user, :account, valid_secs, key) do
    check_time(user.confirmation_sent_at, valid_secs) and
    secure_check(user.confirmation_token, key) and
    change(user, %{confirmed_at: Ecto.DateTime.utc}) |> Config.repo.update
  end
  defp check_key(user, :reset, valid_secs, key) do
    check_time(user.reset_sent_at, valid_secs) and
    secure_check(user.reset_token, key) and user
  end

  defp check_time(sent_at, valid_secs) do
    (sent_at |> Ecto.DateTime.to_erl
     |> :calendar.datetime_to_gregorian_seconds) + valid_secs >
    (:calendar.universal_time |> :calendar.datetime_to_gregorian_seconds)
  end

  defp complete({:ok, _user}, conn, email, mail_func, redirects) do
    mail_func && mail_func.(email)
    handle_info(conn, "Yes, we're in!")
  end
  defp complete(false, conn, email, _, redirects) do
    handle_error(conn, "Confirmation for #{email} failed", redirects)
  end
end
