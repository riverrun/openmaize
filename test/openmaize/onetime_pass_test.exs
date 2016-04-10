defmodule Openmaize.OnetimePassTest do
  use ExUnit.Case
  use Plug.Test

  alias Comeonin.Otp
  alias Openmaize.OnetimePass

  def get_count do
    {megasecs, secs, _} = :os.timestamp()
    trunc((megasecs * 1000000 + secs) / 30)
  end

  def call(otp_type, otp, otpdata, opts) do
    conn(:post, "/twofactor", %{"user" => %{otp_type => otp}})
    |> put_private(:openmaize_otpdata, otpdata)
    |> OnetimePass.call(opts)
  end

  test "check hotp with default options" do
    conn = call("hotp", "816065", {:cookie, :username, "brian", &OpenmaizeJWT.Plug.add_token/3}, [])
    assert conn.resp_cookies["access_token"]
    assert conn.private[:openmaize_info] == 2
    refute conn.private[:openmaize_error]
    conn = call("hotp", "816066", {:cookie, :username, "brian", &OpenmaizeJWT.Plug.add_token/3}, [])
    refute conn.resp_cookies["access_token"]
    assert conn.private[:openmaize_error]
  end

  test "check hotp with last option" do
    conn = call("hotp", "088239", {:cookie, :username, "brian", &OpenmaizeJWT.Plug.add_token/3}, [last: 18])
    assert conn.resp_cookies["access_token"]
    assert conn.private[:openmaize_info] == 19
    refute conn.private[:openmaize_error]
    conn = call("hotp", "088238", {:cookie, :username, "brian", &OpenmaizeJWT.Plug.add_token/3}, [last: 18])
    refute conn.resp_cookies["access_token"]
    assert conn.private[:openmaize_error]
  end

  test "check totp with default options" do
    token = Otp.gen_totp("MFRGGZDFMZTWQ2LK")
    conn = call("totp", token, {:cookie, :email, "brian@mail.com", &OpenmaizeJWT.Plug.add_token/3}, [])
    assert conn.resp_cookies["access_token"]
    assert conn.private[:openmaize_info]
    refute conn.private[:openmaize_error]
  end

end
