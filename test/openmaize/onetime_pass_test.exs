defmodule Openmaize.OnetimePassTest do
  use ExUnit.Case
  use Plug.Test

  alias Comeonin.Otp
  alias Openmaize.{EctoDB, OnetimePass, SessionHelper}

  def get_count do
    {megasecs, secs, _} = :os.timestamp()
    trunc((megasecs * 1000000 + secs) / 30)
  end

  def call(user, opts) do
    conn(:post, "/twofactor", %{"user" => user})
    |> SessionHelper.sign_conn
    |> OnetimePass.call(opts)
  end

  test "init function" do
    assert OnetimePass.init([]) == {nil, :session, []}
  end

  test "check hotp with default options" do
    user = %{"hotp" => "816065", "id" => "5", "uniq" => "username"}
    conn = call(user, {EctoDB, :session, []})
    assert get_session(conn, :user_id) == 5
    assert conn.private[:openmaize_info] == 2
    refute conn.private[:openmaize_error]
    fail = %{"hotp" => "816066", "id" => "5", "uniq" => "username"}
    conn = call(fail, {EctoDB, :session, []})
    assert conn.private[:openmaize_error]
  end

  test "check hotp with last option" do
    user = %{"hotp" => "088239", "id" => "5", "uniq" => "username"}
    conn = call(user, {EctoDB, :session, [last: 18]})
    assert get_session(conn, :user_id) == 5
    assert conn.private[:openmaize_info] == 19
    refute conn.private[:openmaize_error]
    fail = %{"hotp" => "088238", "id" => "5", "uniq" => "username"}
    conn = call(fail, {EctoDB, :session, [last: 18]})
    assert conn.private[:openmaize_error]
  end

  test "check totp with default options" do
    token = Otp.gen_totp("MFRGGZDFMZTWQ2LK")
    user = %{"totp" => token, "id" => "5", "uniq" => "username"}
    conn = call(user, {EctoDB, :session, []})
    assert get_session(conn, :user_id) == 5
    assert conn.private[:openmaize_info]
    refute conn.private[:openmaize_error]
  end

  test "raises error if no db_module is set" do
    user = %{"hotp" => "816065", "id" => "5", "uniq" => "username"}
    assert_raise ArgumentError, "You need to set the db_module value for Openmaize.OnetimePass", fn ->
      call(user, {nil, :session, []})
    end
  end

end
