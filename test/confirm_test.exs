defmodule Openmaize.ConfirmTest do
  use ExUnit.Case
  #use Openmaize.Case
  use Plug.Test

  alias Openmaize.{Confirm, TestRepo, User}


  @valid_link "email=fred%40mail.com&key=lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw"
  @invalid_link "email=wrong%40mail.com&key=lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw"
  @incomplete_link "email=wrong%40mail.com"

  setup_all do
    Application.put_env(:openmaize, :repo, TestRepo)
    Application.put_env(:openmaize, :user_model, User)

    user1 = %{email: "fred@mail.com", role: "user", password: "mangoes&g0oseberries",
      confirmed_at: nil, confirmation_sent_at: Ecto.DateTime.utc}
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

  def call(link, opts) do
    conn(:get, "/confirm?" <> link)
    |> fetch_query_params
    |> Confirm.confirm_email(opts)
  end

  test "Confirmation succeeds for valid token" do
    conn = call(@valid_link, [])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
      {"location", "/login"}
    assert conn.status == 302
  end

  test "Confirmation fails for invalid token" do
    conn = call(@invalid_link, [])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
      {"location", "/"}
    assert conn.status == 302
  end

  test "Confirmation fails for expired token" do
    conn = call(@valid_link, [key_expires_after: 0])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
      {"location", "/"}
    assert conn.status == 302
  end

  test "Invalid link error" do
    conn = call(@incomplete_link, [])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
      {"location", "/"}
    assert conn.status == 302
  end

end
