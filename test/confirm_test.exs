defmodule Openmaize.ConfirmTest do
  use ExUnit.Case
  use Plug.Test

  import Ecto.Changeset
  alias Comeonin.Bcrypt
  alias Openmaize.{Confirm, TestRepo, User}


  @valid_link "email=fred%40mail.com&key=lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw"
  @name_link "username=fred&key=lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw"
  @invalid_link "email=wrong%40mail.com&key=lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw"
  @incomplete_link "email=wrong%40mail.com"

  setup_all do
    Application.put_env(:openmaize, :repo, TestRepo)
    Application.put_env(:openmaize, :user_model, User)

    user1 = %{email: "fred@mail.com", username: "fred", role: "user", password: "mangoes&g0oseberries",
              confirmed_at: nil, confirmation_sent_at: Ecto.DateTime.utc, reset_sent_at: Ecto.DateTime.utc}
    user2 = %{email: "wrong@mail.com", role: "user", password: "mangoes&g0oseberries",
      confirmed_at: nil, confirmation_sent_at: Ecto.DateTime.utc}

    {:ok, _} = %User{}
                |> User.confirm_changeset(user1, "lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw")
                |> TestRepo.insert
    {:ok, _} = %User{}
                |> User.confirm_changeset(user2, "LG9UXGNMpb5LUGEDm62PrwW8c20qZmIw")
                |> TestRepo.insert

    :ok
  end

  setup do
    user = TestRepo.get_by(User, email: "fred@mail.com")
    change(user, %{reset_sent_at: Ecto.DateTime.utc, confirmed_at: nil})
    |> Openmaize.Config.repo.update
    :ok
  end

  def call_confirm(link, opts) do
    conn(:get, "/confirm?" <> link)
    |> fetch_query_params
    |> Confirm.confirm_email(opts)
  end

  def call_reset(password, opts) do
    conn(:post, "/reset",
         %{"user" => %{"email" => "fred@mail.com",
                       "key" => "lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw",
                       "password" => password}})
    |> Confirm.reset_password(opts)
  end

  test "confirmation succeeds for valid token" do
    conn = call_confirm(@valid_link, [])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
      {"location", "/login"}
    assert conn.status == 302
    user = TestRepo.get_by(User, email: "fred@mail.com")
    assert user.confirmed_at
  end

  test "confirmation fails for invalid token" do
    conn = call_confirm(@invalid_link, [])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
      {"location", "/"}
    assert conn.status == 302
    user = TestRepo.get_by(User, email: "fred@mail.com")
    refute user.confirmed_at
  end

  test "confirmation fails for expired token" do
    conn = call_confirm(@valid_link, [key_expires_after: 0])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
      {"location", "/"}
    assert conn.status == 302
    user = TestRepo.get_by(User, email: "fred@mail.com")
    refute user.confirmed_at
  end

  test "invalid link error" do
    conn = call_confirm(@incomplete_link, [])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
      {"location", "/"}
    assert conn.status == 302
    user = TestRepo.get_by(User, email: "fred@mail.com")
    refute user.confirmed_at
  end

  test "confirmation succeeds with different unique id" do
    conn = call_confirm(@name_link, [unique_id: :username])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
      {"location", "/login"}
    assert conn.status == 302
    user = TestRepo.get_by(User, email: "fred@mail.com")
    assert user.confirmed_at
  end

  test "confirmation fails when query fails" do
    conn = call_confirm("key=lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw", [])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
      {"location", "/"}
    assert conn.status == 302
    user = TestRepo.get_by(User, email: "fred@mail.com")
    refute user.confirmed_at
  end

  test "reset password succeeds" do
    password = "my Nipples explode with the light!"
    conn = call_reset(password, [])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
      {"location", "/login"}
    assert conn.status == 302
    user = TestRepo.get_by(User, email: "fred@mail.com")
    assert Bcrypt.checkpw(password, user.password_hash)
    refute user.reset_token
    refute user.reset_sent_at
  end

  test "reset password fails with expired token" do
    password = "C'est bon, la vie"
    conn = call_reset(password, [key_expires_after: 0])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
      {"location", "/"}
    assert conn.status == 302
    user = TestRepo.get_by(User, email: "fred@mail.com")
    refute Bcrypt.checkpw(password, user.password_hash)
    assert user.reset_sent_at
  end

  test "reset password fails when reset_sent_at is nil" do
    user = TestRepo.get_by(User, email: "fred@mail.com")
    change(user, %{reset_sent_at: nil})
    |> Openmaize.Config.repo.update
    conn = call_reset("password", [])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
      {"location", "/"}
    assert conn.status == 302
  end

end
