defmodule Openmaize.Confirm.Base do
  @moduledoc """
  Base implementation of the email confirmation module.

  This is used by both the Openmaize.Confirm and Openmaize.ResetPassword
  modules.

  You can also use it to create your own custom module / plug.
  """

  @doc false
  defmacro __using__(_) do
    quote do
      @behaviour Plug

      import unquote(__MODULE__)

      @doc false
      def init(opts) do
        {Keyword.get(opts, :key_expires_after, 120),
         Keyword.get(opts, :unique_id, :email),
         Keyword.get(opts, :mail_function)}
      end

      @doc false
      def call(%Plug.Conn{params: %{"key" => key} = user_params} = conn, opts)
      when byte_size(key) == 32 do
        check_user_key(conn, user_params, key, :nopassword, opts)
      end
      def call(conn, {_, _, _}), do: invalid_link_error(conn)

      defoverridable [init: 1, call: 2]
    end
  end

  import Plug.Conn
  import Comeonin.Tools
  alias Openmaize.Config

  @doc """
  Check the user key and, if necessary, the user password.

  If this function is successful, the database will be updated, and an
  `openmaize_info` message will be added to the conn. If there is an error,
  an `openmaize_error` message will be added to the conn.
  """
  def check_user_key(conn, user_params, key, password,
   {key_expiry, uniq, mail_func}) do
    case Map.get(user_params, to_string(uniq)) do
      nil -> finalize(nil, conn, nil, mail_func)
      user_id ->
        user_id
        |> Config.db_module.find_user(uniq)
        |> check_key(key, key_expiry * 60, password)
        |> finalize(conn, user_id, mail_func)
    end
  end

  @doc """
  Error message in the case of an invalid link.
  """
  def invalid_link_error(conn) do
    put_private(conn, :openmaize_error, "Invalid link")
  end

  defp check_key(nil, _, _, _), do: false
  defp check_key(user, key, valid_secs, :nopassword) do
    Config.db_module.check_time(user.confirmation_sent_at, valid_secs) and
    secure_check(user.confirmation_token, key) and
    Config.db_module.user_confirmed(user)
  end
  defp check_key(user, key, valid_secs, password) do
    Config.db_module.check_time(user.reset_sent_at, valid_secs) and
    secure_check(user.reset_token, key) and
    Config.db_module.password_reset(user, password)
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
