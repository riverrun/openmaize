defmodule Openmaize.Confirm.Base do
  @moduledoc """
  Functions used with email confirmation.

  This is used by both the Openmaize.Confirm and Openmaize.ResetPassword
  modules.
  """

  import Plug.Conn
  import Comeonin.Tools
  alias Openmaize.Database, as: DB

  @doc """
  Check the user key and, if necessary, the user password.

  If this function is successful, the database will be updated, and an
  `openmaize_info` message will be added to the conn. If there is an error,
  an `openmaize_error` message will be added to the conn.
  """
  def check_user_key(conn, user_params, key, password,
   {repo, user_model, {key_expiry, uniq, mail_func}}) do
    case Map.get(user_params, to_string(uniq)) do
      nil -> finalize(nil, conn, nil, mail_func)
      user_id ->
        repo.get_by(user_model, [{uniq, user_id}])
        |> check_key(repo, key, key_expiry * 60, password)
        |> finalize(conn, user_id, mail_func)
    end
  end

  @doc """
  Error message in the case of an invalid link.
  """
  def invalid_link_error(conn) do
    put_private(conn, :openmaize_error, "Invalid link")
  end

  defp check_key(_, nil, _, _, _), do: false
  defp check_key(%{confirmed_at: nil} = user, repo, key, valid_secs, :nopassword) do
    DB.check_time(user.confirmation_sent_at, valid_secs) and
    secure_check(user.confirmation_token, key) and
    DB.user_confirmed(user, repo)
  end
  defp check_key(_, _, _, _, :nopassword), do: {:error, "User account already confirmed"}
  defp check_key(user, repo, key, valid_secs, password) do
    DB.check_time(user.reset_sent_at, valid_secs) and
    secure_check(user.reset_token, key) and
    DB.password_reset(user, password, repo)
  end

  defp finalize({:ok, user}, conn, _, mail_func) do
    mail_func && mail_func.(user.email)
    put_private(conn, :openmaize_info, "Account successfully confirmed")
  end
  defp finalize({:error, message}, conn, _user_id, _) do
    put_private(conn, :openmaize_error, message)
  end
  defp finalize(_, conn, user_id, _) do
    put_private(conn, :openmaize_error, "Confirmation for #{user_id} failed")
  end
end
