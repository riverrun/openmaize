defmodule Openmaize.RememberTest do
  use Openmaize.TestCase
  use Plug.Test

  alias Openmaize.{Authenticate, Remember, SessionHelper, TestRepo, TestUser, UserHelpers}

  setup do
    {:ok, user} = UserHelpers.add_user()
    {:ok, other} = UserHelpers.add_confirmed()
    conn = conn(:get, "/")
            |> SessionHelper.sign_conn
            |> Remember.add_cookie(user.id)

    newconn = conn(:get, "/")
              |> recycle_cookies(conn)
              |> SessionHelper.sign_conn

    {:ok, %{conn: conn, newconn: newconn, other: other}}
  end

  test "init function" do
    assert Remember.init([]) == {Openmaize.Repo, Openmaize.User}
  end

  test "call remember with default options", %{newconn: newconn} do
    newconn = Remember.call(newconn, {TestRepo, TestUser})
    %{current_user: user} = newconn.assigns
    assert user.username == "fred"
    assert user.role == "user"
  end

  test "error message is sent when the cookie is invalid", %{conn: conn} do
    invalid = "SFMyNTY.MQ.yX9edpVZtRiJwMsoARY8QJqXfKnQpicssKlqGPjtoUw"
    conn = put_resp_cookie(conn, "remember_me", invalid,
     [http_only: true, max_age: 604_800])
    newconn = conn(:get, "/")
              |> recycle_cookies(conn)
              |> SessionHelper.sign_conn
              |> Remember.call({TestRepo, TestUser})
    assert newconn.private[:openmaize_error] == "Invalid cookie"
    refute newconn.assigns[:current_user]
  end

  test "call remember with no remember cookie" do
    conn = conn(:get, "/")
            |> SessionHelper.sign_conn
            |> Remember.call({TestRepo, TestUser})
    refute conn.assigns[:current_user]
  end

  test "call remember with current_user already set", %{newconn: newconn, other: other} do
    newconn = newconn
              |> put_session(:user_id, other.id)
              |> Authenticate.call({TestRepo, TestUser})
              |> Remember.call({TestRepo, TestUser})
    %{current_user: user} = newconn.assigns
    assert user.id == other.id
    assert user.email == other.email
  end

  test "add cookie", %{conn: conn} do
    remember = conn.resp_cookies["remember_me"]
    assert remember.max_age == 604_800
    assert remember.value =~ "SFMyNTY"
  end

  test "output to current_user does not contain password_hash or otp_secret" , %{newconn: newconn} do
    newconn = Remember.call(newconn, {TestRepo, TestUser})
    %{current_user: user} = newconn.assigns
    refute Map.has_key?(user, :password_hash)
    refute Map.has_key?(user, :otp_secret)
  end

end
