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
  """
  def call(%Plug.Conn{req_cookies: %{"remember_me" => remember}} = conn, db_module) do
    if conn.assigns[:current_user] do
      conn
    else
      case verify_cookie(remember, conn.secret_key_base, Config.remember_salt) do
        {:ok, user_id} -> db_module.find_user_byid(user_id) |> handle_auth(conn)
        _ -> put_private(conn, :openmaize_error, "Invalid cookie")
      end
    end
  end
  def call(conn, _), do: conn

  def add_cookie(conn, content) do
    key = conn.secret_key_base |> KeyGenerator.generate(Config.remember_salt)
    cookie = MessageVerifier.sign(content, key)
    put_resp_cookie(conn, "remember_me", cookie, [http_only: true, max_age: 604_800])
  end

  def sign_cookie(conn, content) do
    key = conn.secret_key_base |> KeyGenerator.generate(Config.remember_salt)
    MessageVerifier.sign(content, key)
  end

  def verify_cookie(_, _, nil) do
    raise ArgumentError, "You need to set the `remember_salt` config value"
  end
  def verify_cookie(_, secret, _) when byte_size(secret) < 64 do
    raise ArgumentError, "The secret must be 64 bytes or longer"
  end
  def verify_cookie(remember, secret, salt) do
    key = secret |> KeyGenerator.generate(salt)
    MessageVerifier.verify(remember, key)
  end

  defp handle_auth(nil, conn) do
    put_private(conn, :openmaize_error, "Invalid user id")
  end
  defp handle_auth(%{id: id} = user, conn) do
    put_session(conn, :user_id, id) |> assign(:current_user, user)
  end
end
