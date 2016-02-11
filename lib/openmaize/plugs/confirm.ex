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

  @doc """
  """
  def confirm_email(%Plug.Conn{params: %{"key" => key} = user_params} = conn, opts)
  when byte_size(key) == 32 do
    check_user_key(conn, user_params, key, :nopassword, get_opts(opts))
  end
  def confirm_email(conn, opts), do: invalid_link_error(conn, opts)

  @doc """
  """
  def reset_password(%Plug.Conn{params: %{"key" => key, "password" => password} = user_params} = conn, opts)
  when byte_size(key) == 32 do
    Signup.create_user(%{"password" => password}) # validate changeset first
    check_user_key(conn, user_params, key, password, get_opts(opts))
  end
  def reset_password(conn, opts), do: invalid_link_error(conn, opts)

  defp get_opts(opts) do
    {Keyword.get(opts, :key_expires_after, 1440),
     Keyword.get(opts, :unique_id, :email),
     Keyword.get(opts, :mail_function),
     Keyword.get(opts, :redirects, true),
     Keyword.get(opts, :query_function, &QueryTools.find_user/2)}
  end

  defp check_user_key(conn, user_params, key, password,
                      {key_expiry, uniq, mail_func, redirects, query_func}) do
    user_id = Map.get(user_params, to_string(uniq))
    user_id
    |> URI.decode_www_form
    |> query_func.(uniq)
    |> check_key(key, key_expiry * 60, password)
    |> finalize(conn, user_id, mail_func, redirects)
  end

  defp check_key({:error, message}, _, _, _), do: IO.inspect message
  defp check_key(user, key, valid_secs, :nopassword) do
    check_time(user.confirmation_sent_at, valid_secs) and
    secure_check(user.confirmation_token, key) and
    change(user, %{confirmed_at: Ecto.DateTime.utc}) |> Config.repo.update
  end
  defp check_key(user, key, valid_secs, password) do
    check_time(user.reset_sent_at, valid_secs) and
    secure_check(user.reset_token, key) and
    Signup.create_user(user, %{"password" => password}) |> Config.repo.update
  end

  defp check_time(sent_at, valid_secs) do
    (sent_at |> Ecto.DateTime.to_erl
     |> :calendar.datetime_to_gregorian_seconds) + valid_secs >
    (:calendar.universal_time |> :calendar.datetime_to_gregorian_seconds)
  end

  defp finalize({:ok, user}, conn, _, mail_func, redirects) do
    mail_func && mail_func.(user.email)
    put_message(conn, %{"info" => "Account successfully confirmed"}, redirects)
  end
  defp finalize(false, conn, user_id, _, redirects) do
    put_message(conn, "logout", %{"error" => "Confirmation for #{user_id} failed"}, redirects)
  end

  defp invalid_link_error(conn, opts) do
    redirects = Keyword.get(opts, :redirects, true)
    put_message(conn, "logout", %{"error" => "Invalid link"}, redirects)
  end
end
