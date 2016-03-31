defmodule Openmaize.OnetimePass do
  @moduledoc """
  ADD INFO ABOUT CREATING HOTPs AND TOTPs WITH COMEONIN
  """

  import Plug.Conn
  alias Comeonin.Otp

  @behaviour Plug

  def init(opts) do
    opts
  end

  @doc """
  """
  def call(%Plug.Conn{params: %{"user" => %{"hotp" => hotp}}} = conn, opts) do
    Otp.check_hotp(hotp, Config.otp_secret, opts) |> handle_auth(conn)
  end
  def call(%Plug.Conn{params: %{"user" => %{"totp" => totp}}} = conn, opts) do
    Otp.check_totp(totp, Config.otp_secret, opts) |> handle_auth(conn)
  end

  def handle_auth(false, conn) do
    put_private(conn, :openmaize_error, "Invalid credentials")
  end
  def handle_auth(last, conn) do
    put_private(conn, :openmaize_info, last)
  end
end
