defmodule Openmaize.ConfirmTest do
  use ExUnit.Case
  #use Openmaize.Case
  use Plug.Test

  import Ecto.Changeset
  alias Comeonin.Bcrypt
  alias Openmaize.{Confirm, QueryTools, TestRepo, User}


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
                |> User.auth_changeset(user1, "lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw")
                |> TestRepo.insert
    {:ok, _} = %User{}
                |> User.auth_changeset(user2, "LG9UXGNMpb5LUGEDm62PrwW8c20qZmIw")
                |> TestRepo.insert

    :ok
  end

  setup do
    user = QueryTools.find_user("fred@mail.com", :email)
    change(user, %{confirmed_at: nil}) |> Openmaize.Config.repo.update
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

  test "Confirmation succeeds for valid token" do
    conn = call_confirm(@valid_link, [])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
      {"location", "/login"}
    assert conn.status == 302
    user = QueryTools.find_user("fred@mail.com", :email)
    assert user.confirmed_at
  end

  test "Confirmation fails for invalid token" do
    conn = call_confirm(@invalid_link, [])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
      {"location", "/"}
    assert conn.status == 302
    user = QueryTools.find_user("fred@mail.com", :email)
    refute user.confirmed_at
  end

  test "Confirmation fails for expired token" do
    conn = call_confirm(@valid_link, [key_expires_after: 0])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
      {"location", "/"}
    assert conn.status == 302
    user = QueryTools.find_user("fred@mail.com", :email)
    refute user.confirmed_at
  end

  test "Invalid link error" do
    conn = call_confirm(@incomplete_link, [])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
      {"location", "/"}
    assert conn.status == 302
    user = QueryTools.find_user("fred@mail.com", :email)
    refute user.confirmed_at
  end

  test "Confirmation succeeds with different unique id" do
    conn = call_confirm(@name_link, [unique_id: :username])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
      {"location", "/login"}
    assert conn.status == 302
    user = QueryTools.find_user("fred@mail.com", :email)
    assert user.confirmed_at
  end

  test "Confirmation fails when query fails" do
    conn = call_confirm("key=lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw", [])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
      {"location", "/"}
    assert conn.status == 302
    user = QueryTools.find_user("fred@mail.com", :email)
    refute user.confirmed_at
  end

  test "Reset password succeeds" do
    password = "my Nipples explode with the light!"
    conn = call_reset(password, [])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
      {"location", "/login"}
    assert conn.status == 302
    user = QueryTools.find_user("fred@mail.com", :email)
    assert Bcrypt.checkpw(password, user.password_hash)
  end

  test "Reset password fails with expired token" do
    password = "C'est bon, la vie"
    conn = call_reset(password, [key_expires_after: 0])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
      {"location", "/"}
    assert conn.status == 302
    user = QueryTools.find_user("fred@mail.com", :email)
    refute Bcrypt.checkpw(password, user.password_hash)
  end

end
