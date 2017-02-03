defmodule Openmaize.AuthenticateTest do
  use ExUnit.Case
  use Plug.Test

  alias Openmaize.{Authenticate, SessionHelper, TestRepo, TestUser}

  def call(id) do
    conn(:get, "/")
    |> SessionHelper.sign_conn
    |> put_session(:user_id, id)
    |> Authenticate.call({TestRepo, TestUser})
  end

  test "current user in session" do
    conn = call(1)
    %{current_user: user} = conn.assigns
    assert user.username == "fred"
    assert user.role == "user"
  end

  test "no user found" do
    conn = call(1000)
    assert conn.assigns == %{current_user: nil}
  end

  test "user removed from session" do
    conn = call(1) |> configure_session(drop: true)
    newconn = conn(:get, "/")
              |> recycle_cookies(conn)
              |> SessionHelper.sign_conn
              |> Authenticate.call({TestRepo, TestUser})
    assert newconn.assigns == %{current_user: nil}
  end

end
