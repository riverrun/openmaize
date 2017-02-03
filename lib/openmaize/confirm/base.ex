defmodule Openmaize.Confirm.Base do
  @moduledoc """
  Functions used with email confirmation.

  This is used by both the Openmaize.Confirm and Openmaize.ResetPassword
  modules.
  """

  @doc false
  defmacro __using__(_) do
    quote do
      @behaviour Plug

      import unquote(__MODULE__)

      @doc false
      def init(opts) do
        {Keyword.get(opts, :repo, Openmaize.Utils.default_repo),
        Keyword.get(opts, :user_model, Openmaize.Utils.default_user_model),
        {Keyword.get(opts, :key_expires_after, 60),
        Keyword.get(opts, :mail_function, &IO.puts/1)}}
      end

      @doc false
      def call(%Plug.Conn{params: params} = conn, opts) do
        check_confirm conn, unpack_params(params), opts
      end

      def unpack_params(%{"email" => email, "key" => key}), do: {:email, email, key, :nopassword}
      def unpack_params(_), do: nil

      defoverridable [init: 1, call: 2, unpack_params: 1]
    end
  end

  import Plug.Conn
  import Comeonin.Tools
  alias Openmaize.Database, as: DB

  def check_confirm(conn, {uniq, user_id, key, password},
    {repo, user_model, {key_expiry, mail_func}}) when byte_size(key) == 32 do
    repo.get_by(user_model, [{uniq, user_id}])
    |> check_key(repo, key, key_expiry * 60, password)
    |> finalize(conn, user_id, mail_func)
  end
  def check_confirm(conn, _, _) do
    put_private(conn, :openmaize_error, "Invalid link")
  end

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
    mail_func.(user.email)
    put_private(conn, :openmaize_info, "Account successfully confirmed")
  end
  defp finalize({:error, message}, conn, _user_id, _) do
    put_private(conn, :openmaize_error, message)
  end
  defp finalize(_, conn, user_id, _) do
    put_private(conn, :openmaize_error, "Confirmation for #{user_id} failed")
  end
end
