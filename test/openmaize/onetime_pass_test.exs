defmodule Openmaize.OnetimePassTest do
  use ExUnit.Case
  use Plug.Test

  alias Comeonin.Otp
  alias Openmaize.OnetimePass

  def get_count do
    {megasecs, secs, _} = :os.timestamp()
    trunc((megasecs * 1000000 + secs) / 30)
  end

  def call(uniq, name, otp_type, otp, opts) do
    conn(:post, "/twofactor",
         %{"user" => %{uniq => name, otp_type => otp}})
    |> OnetimePass.call(opts)
  end

  test "check hotp with default options" do
    conn = call("username", "ray", "hotp", "816065", {:username, []})
    assert conn.private[:openmaize_info] == 2
    refute conn.private[:openmaize_error]
    conn = call("username", "ray", "hotp", "816066", {:username, []})
    assert conn.private[:openmaize_error]
  end

  test "check hotp with last option" do
    conn = call("username", "ray", "hotp", "088239", {:username, [last: 18]})
    assert conn.private[:openmaize_info] == 19
    refute conn.private[:openmaize_error]
    conn = call("username", "ray", "hotp", "088238", {:username, [last: 18]})
    assert conn.private[:openmaize_error]
  end

  test "check totp with default options" do
    token = Otp.gen_totp("MFRGGZDFMZTWQ2LK")
    conn = call("email", "ray@mail.com", "totp", token, {:email, []})
    assert conn.private[:openmaize_info]
    refute conn.private[:openmaize_error]
  end

end
