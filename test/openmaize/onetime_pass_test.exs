defmodule Openmaize.OnetimePassTest do
  use ExUnit.Case
  use Plug.Test

  alias Comeonin.Otp
  alias Openmaize.OnetimePass
  alias OpenmaizeJWT.{Tools, Verify}

  def get_count do
    {megasecs, secs, _} = :os.timestamp()
    trunc((megasecs * 1000000 + secs) / 30)
  end

  def call(user, opts) do
    conn(:post, "/twofactor", %{"user" => user}) |> OnetimePass.call(opts)
  end

  test "check hotp with default options" do
    user = %{"hotp" => "816065", "storage" => "cookie", "uniq" => "username", "id" => "5"}
    conn = call(user, {&OpenmaizeJWT.Plug.add_token/5, []})
    assert conn.resp_cookies["access_token"]
    assert conn.private[:openmaize_info] == 2
    refute conn.private[:openmaize_error]
    fail = %{"hotp" => "816066", "storage" => "cookie", "uniq" => "username",
     "id" => "5", "override_exp" => nil}
    conn = call(fail, {&OpenmaizeJWT.Plug.add_token/5, []})
    refute conn.resp_cookies["access_token"]
    assert conn.private[:openmaize_error]
  end

  test "check hotp with last option" do
    user = %{"hotp" => "088239", "storage" => "cookie", "uniq" => "username", "id" => "5"}
    conn = call(user, {&OpenmaizeJWT.Plug.add_token/5, [last: 18]})
    assert conn.resp_cookies["access_token"]
    assert conn.private[:openmaize_info] == 19
    refute conn.private[:openmaize_error]
    fail = %{"hotp" => "088238", "storage" => "cookie", "uniq" => "username",
     "id" => "5", "override_exp" => nil}
    conn = call(fail, {&OpenmaizeJWT.Plug.add_token/5, [last: 18]})
    refute conn.resp_cookies["access_token"]
    assert conn.private[:openmaize_error]
  end

  test "check totp with default options" do
    token = Otp.gen_totp("MFRGGZDFMZTWQ2LK")
    user = %{"totp" => token, "storage" => "cookie", "uniq" => "email",
     "id" => "5", "override_exp" => nil}
    conn = call(user, {&OpenmaizeJWT.Plug.add_token/5, []})
    assert conn.resp_cookies["access_token"]
    assert conn.private[:openmaize_info]
    refute conn.private[:openmaize_error]
  end

  test "check totp and override default token validity" do
    token = Otp.gen_totp("MFRGGZDFMZTWQ2LK")
    user = %{"totp" => token, "storage" => "cookie", "uniq" => "email",
     "id" => "5", "override_exp" => "10080"}
    conn = call(user, {&OpenmaizeJWT.Plug.add_token/5, []})
    token = conn.resp_cookies["access_token"]
    assert token.max_age == 604_800
    {:ok, %{exp: exp}} = Verify.verify_token token.value
    assert exp - Tools.current_time > 500_000_000
  end

end
