defmodule Openmaize.RememberTest do
  use ExUnit.Case
  use Plug.Test

  alias Openmaize.{Config, EctoDB, Remember, SessionHelper}

  setup do
    conn = conn(:get, "/") |> SessionHelper.sign_conn
    {:ok, %{conn: conn}}
  end

  test "init function" do
    assert Remember.init([]) == nil
  end

  test "call remember with default options", %{conn: conn} do
    conn = Remember.add_cookie(conn, "1")
    newconn = conn(:get, "/")
              |> recycle_cookies(conn)
              |> SessionHelper.sign_conn
              |> Remember.call(EctoDB)
    %{current_user: user} = newconn.assigns
    assert user.id == 1
    assert user.username == "fred"
    assert user.role == "user"
  end

  test "call remember with no remember cookie" do
  end

  test "call remember with current_user already set" do
  end

  test "sign and verify cookie", %{conn: conn} do
    cookie = Remember.sign_cookie(conn, "1")
    assert cookie == "MQ==##R2qbEDO7u26NYKPV7lfNdHaGqCM="
    assert Remember.verify_cookie(cookie, conn.secret_key_base,
     Config.remember_salt) == {:ok, "1"}
  end

  test "add cookie", %{conn: conn} do
    conn = Remember.add_cookie(conn, "1")
    remember = conn.resp_cookies["remember_me"]
    assert remember.max_age == 604_800
    assert remember.value == "MQ==##R2qbEDO7u26NYKPV7lfNdHaGqCM="
  end

end
