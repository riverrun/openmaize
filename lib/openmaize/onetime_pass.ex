defmodule Openmaize.OnetimePass do
  @moduledoc """
  """

  import Plug.Conn
  alias Comeonin.Otp
  alias Openmaize.Config

  @behaviour Plug

  def init(opts) do
    Keyword.pop opts, :unique_id, :username
  end

  @doc """
  """
  def call(%Plug.Conn{params: %{"user" => user_params}} = conn, {uniq, opts}) do
    case Map.get(user_params, to_string(uniq)) do
      nil -> handle_auth(false, conn)
      user_id ->
        Config.db_module.find_user(user_id, uniq)
        |> check_key(user_params, opts)
        |> handle_auth(conn)
    end
  end

  def check_key(user, %{"hotp" => hotp}, opts) do
    Otp.check_hotp(hotp, user.otp_secret, opts)
  end
  def check_key(user, %{"totp" => totp}, opts) do
    Otp.check_totp(totp, user.otp_secret, opts)
  end

  def handle_auth(false, conn) do
    put_private(conn, :openmaize_error, "Invalid credentials")
  end
  def handle_auth(last, conn) do
    put_private(conn, :openmaize_info, last)
  end
end
