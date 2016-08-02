defmodule Openmaize.Remember do
  @moduledoc """
  Module to help authenticate users who have persistent (remember me)
  access enabled.

  This needs to be run after `plug Openmaize.Authenticate`.
  """

  @behaviour Plug

  import Plug.Conn
  alias Openmaize.Config
  alias Plug.Crypto.{KeyGenerator, MessageVerifier}

  def init(opts) do
    Keyword.get opts, :db_module
  end

  @doc """
  Check for a `remember_me` cookie, and if the current_user is not set,
  authenticate the user using this cookie.

  If the check is successful, the user will be added to the current
  session and to the current_user.

  If the check is unsuccessful, an error message will be sent to
  `conn.private.openmaize_error`.
  """
  def call(%Plug.Conn{req_cookies: %{"remember_me" => remember}} = conn, db_module) do
    if conn.assigns[:current_user] do
      conn
    else
      valid_cookie?(remember, conn.secret_key_base, Config.remember_salt)
      |> verify_cookie(conn, db_module)
    end
  end
  def call(conn, _), do: conn

  @doc """
  Sign cookie and add it to the conn.

  The `max_age` is set to 604_800 seconds (7 days) by default.
  """
  def add_cookie(conn, data, max_age \\ 604_800)
  def add_cookie(conn, data, max_age) when is_binary(data) do
    salt = Config.remember_salt ||
      raise ArgumentError, "You need to set the `remember_salt` config value"
    key = KeyGenerator.generate(conn.secret_key_base, salt)
    cookie = MessageVerifier.sign(data, key)
    put_resp_cookie(conn, "remember_me", cookie, [http_only: true, max_age: max_age])
  end
  def add_cookie(conn, data, max_age), do: add_cookie(conn, to_string(data), max_age)

  @doc """
  Delete the remember_me cookie.
  """
  def delete_rem_cookie(conn) do
    register_before_send(conn, &delete_resp_cookie(&1, "remember_me"))
  end

  @doc """
  Generate a signing salt for use with this module.

  After running gen_salt, add the following lines to your config:

      config :openmaize,
        remember_salt: "generated salt"
  """
  def gen_salt(length \\ 16)
  def gen_salt(length) when length > 15 do
    :crypto.strong_rand_bytes(length) |> Base.encode64 |> binary_part(0, length)
  end
  def gen_salt(_) do
    raise ArgumentError, "The salt should be 16 bytes or longer"
  end

  defp valid_cookie?(_, _, salt) when is_nil(salt) or byte_size(salt) < 16 do
    raise ArgumentError, "You need to set the `remember_salt` config value" <>
    " to a value that is 16 bytes or longer"
  end
  defp valid_cookie?(_, secret, _) when is_nil(secret) or byte_size(secret) < 64 do
    raise ArgumentError, "The secret should be 64 bytes or longer"
  end
  defp valid_cookie?(remember, secret, salt) do
    key = secret |> KeyGenerator.generate(salt)
    MessageVerifier.verify(remember, key)
  end

  defp verify_cookie({:ok, user_id}, conn, db_module) do
    db_module.find_user_byid(user_id) |> handle_auth(conn)
  end
  defp verify_cookie(_, conn, _) do
    put_private(conn, :openmaize_error, "Invalid cookie")
  end

  defp handle_auth(nil, conn) do
    put_private(conn, :openmaize_error, "Invalid user id")
  end
  defp handle_auth(%{id: id} = user, conn) do
    put_session(conn, :user_id, id) |> assign(:current_user, user)
  end
end
