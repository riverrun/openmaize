defmodule Openmaize.OnetimePassTest do
  use ExUnit.Case
  use Plug.Test

  alias Comeonin.Otp
  alias Openmaize.OnetimePass

  def get_count do
    {megasecs, secs, _} = :os.timestamp()
    trunc((megasecs * 1000000 + secs) / 30)
  end

  def call(user, opts) do
    conn(:post, "/twofactor", %{"user" => user}) |> OnetimePass.call(opts)
  end

  test "check hotp with default options" do
    user = %{"hotp" => "816065", "storage" => "cookie", "uniq" => "username", "id" => "5"}
    conn = call(user, {&OpenmaizeJWT.Plug.add_token/4, []})
    assert conn.resp_cookies["access_token"]
    assert conn.private[:openmaize_info] == 2
    refute conn.private[:openmaize_error]
    fail = %{"hotp" => "816066", "storage" => "cookie", "uniq" => "username", "id" => "5"}
    conn = call(fail, {&OpenmaizeJWT.Plug.add_token/4, []})
    refute conn.resp_cookies["access_token"]
    assert conn.private[:openmaize_error]
  end

  test "check hotp with last option" do
    user = %{"hotp" => "088239", "storage" => "cookie", "uniq" => "username", "id" => "5"}
    conn = call(user, {&OpenmaizeJWT.Plug.add_token/4, [last: 18]})
    assert conn.resp_cookies["access_token"]
    assert conn.private[:openmaize_info] == 19
    refute conn.private[:openmaize_error]
    fail = %{"hotp" => "088238", "storage" => "cookie", "uniq" => "username", "id" => "5"}
    conn = call(fail, {&OpenmaizeJWT.Plug.add_token/4, [last: 18]})
    refute conn.resp_cookies["access_token"]
    assert conn.private[:openmaize_error]
  end

  test "check totp with default options" do
    token = Otp.gen_totp("MFRGGZDFMZTWQ2LK")
    user = %{"totp" => token, "storage" => "cookie", "uniq" => "email", "id" => "5"}
    conn = call(user, {&OpenmaizeJWT.Plug.add_token/4, []})
    assert conn.resp_cookies["access_token"]
    assert conn.private[:openmaize_info]
    refute conn.private[:openmaize_error]
  end

end
