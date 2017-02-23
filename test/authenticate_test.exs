defmodule Openmaize.AuthenticateTest do
  use Openmaize.TestCase
  use Plug.Test

  alias Openmaize.{Authenticate, SessionHelper, TestRepo, TestUser, UserHelpers}

  setup do
    {:ok, user} = UserHelpers.add_confirmed()
    {:ok, %{user: user}}
  end

  def call(id) do
    conn(:get, "/")
    |> SessionHelper.sign_conn
    |> put_session(:user_id, id)
    |> Authenticate.call({TestRepo, TestUser})
  end

  test "current user in session", %{user: user} do
    conn = call(user.id)
    %{current_user: user} = conn.assigns
    assert user.username == "ray"
    assert user.role == "user"
  end

  test "no user found", %{user: user} do
    conn = call(user.id + 1)
    assert conn.assigns == %{current_user: nil}
  end

  test "user removed from session", %{user: user} do
    conn = call(user.id) |> configure_session(drop: true)
    newconn = conn(:get, "/")
              |> recycle_cookies(conn)
              |> SessionHelper.sign_conn
              |> Authenticate.call({TestRepo, TestUser})
    assert newconn.assigns == %{current_user: nil}
  end

  test "output to current_user does not contain password_hash or otp_secret", %{user: user} do
    conn = call(user.id)
    %{current_user: user} = conn.assigns
    refute Map.has_key?(user, :password_hash)
    refute Map.has_key?(user, :otp_secret)
  end

end
