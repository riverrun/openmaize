defmodule Openmaize.Confirm.Base do
  @moduledoc """
  Base module for handling email confirmation.

  This is used by both the Openmaize.ConfirmEmail and Openmaize.ResetPassword
  modules.
  """

  @doc false
  defmacro __using__(_) do
    quote do
      @behaviour Plug

      import unquote(__MODULE__)

      def init(opts) do
        {Keyword.get(opts, :repo, Openmaize.Utils.default_repo),
        Keyword.get(opts, :user_model, Openmaize.Utils.default_user_model),
        {Keyword.get(opts, :key_expires_after, 60),
        Keyword.get(opts, :mail_function, &IO.puts/1)}}
      end

      def call(%Plug.Conn{params: params} = conn, opts) do
        check_confirm conn, unpack_params(params), opts
      end

      def unpack_params(%{"email" => email, "key" => key}), do: {:email, email, key, :nopass}
      def unpack_params(_), do: nil

      defoverridable [init: 1, call: 2, unpack_params: 1]
    end
  end

  import Plug.Conn
  import Comeonin.Tools
  alias Openmaize.Database, as: DB
  alias Openmaize.Logger

  def check_confirm(conn, {uniq, user_id, key, password},
    {repo, user_model, {key_expiry, mail_func}}) when byte_size(key) == 32 do
    repo.get_by(user_model, [{uniq, user_id}])
    |> check_key(repo, key, key_expiry * 60, password)
    |> finalize(conn, user_id, mail_func, password)
  end
  def check_confirm(conn, _, _) do
    Logger.warn conn, "-", "invalid query string", "query:#{conn.query_string}"
    put_private(conn, :openmaize_error, "Invalid credentials")
  end

  defp check_key(nil, _, _, _, _), do: {:error, "invalid credentials"}
  defp check_key(%{confirmed_at: nil} = user, repo, key, valid_secs, :nopass) do
    DB.check_time(user.confirmation_sent_at, valid_secs) and
    secure_check(user.confirmation_token, key) and
    DB.user_confirmed(user, repo) || {:error, "invalid token"}
  end
  defp check_key(_, _, _, _, :nopass), do: {:error, "user account already confirmed"}
  defp check_key(user, repo, key, valid_secs, password) do
    DB.check_time(user.reset_sent_at, valid_secs) and
    secure_check(user.reset_token, key) and
    DB.password_reset(user, password, repo) || {:error, "invalid token"}
  end

  defp finalize({:ok, user}, conn, user_id, mail_func, password) do
    message = if password == :nopass, do: "account confirmed", else: "password reset"
    Logger.info conn, user_id, message, Logger.current_user_info(conn)
    mail_func.(user.email)
    put_private(conn, :openmaize_info, String.capitalize(message))
  end
  defp finalize({:error, message}, conn, user_id, _, _) do
    Logger.warn conn, user_id, message, Logger.current_user_info(conn)
    put_private(conn, :openmaize_error, "Invalid credentials")
  end
end
