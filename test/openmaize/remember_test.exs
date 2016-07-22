defmodule Openmaize.RememberTest do
  use ExUnit.Case
  use Plug.Test

  alias Openmaize.{Authenticate, EctoDB, Remember, SessionHelper}

  setup do
    conn = conn(:get, "/")
            |> SessionHelper.sign_conn
            |> Remember.add_cookie("1")

    {:ok, %{conn: conn}}
  end

  test "init function" do
    assert Remember.init([]) == nil
  end

  test "call remember with default options", %{conn: conn} do
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
    conn = conn(:get, "/")
            |> SessionHelper.sign_conn
            |> Remember.call(EctoDB)
    refute conn.assigns[:current_user]
  end

  test "call remember with current_user already set", %{conn: conn} do
    newconn = conn(:get, "/")
              |> recycle_cookies(conn)
              |> SessionHelper.sign_conn
              |> put_session(:user_id, 2)
              |> Authenticate.call(EctoDB)
              |> Remember.call(EctoDB)
    %{current_user: user} = newconn.assigns
    assert user.id == 2
    assert user.username == "dim"
    assert user.role == "user"
  end

  test "add cookie", %{conn: conn} do
    remember = conn.resp_cookies["remember_me"]
    assert remember.max_age == 604_800
    assert remember.value == "MQ==##R2qbEDO7u26NYKPV7lfNdHaGqCM="
  end

end
