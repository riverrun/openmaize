defmodule Openmaize.LoginTest do
  use ExUnit.Case
  use Plug.Test

  alias Openmaize.{DB, Login, LoginTools, TestRepo, User}

  setup_all do
    user = %{email: "ray@mail.com", username: "ray", role: "user", password: "hard2guess",
            phone: "081555555", confirmed_at: Ecto.DateTime.utc}
    {:ok, _} = %User{} |> User.auth_changeset(user) |> TestRepo.insert

    :ok
  end

  def call(name, password, uniq, opts) do
    conn(:post, "/login",
         %{"user" => %{uniq => name, "password" => password}})
    |> Login.call(opts)
  end

  test "login succeeds with username" do
    opts = {true, :cookie, {0, 1440}, :username, &DB.find_user/2}
    conn = call("ray", "hard2guess", "username", opts)
    assert List.keyfind(conn.resp_headers, "location", 0) ==
      {"location", "/users"}
    assert conn.status == 302
    assert conn.resp_cookies["access_token"]
  end

  test "login succeeds with email" do
    opts = {true, :cookie, {0, 1440}, :email, &DB.find_user/2}
    conn = call("ray@mail.com", "hard2guess", "email", opts)
    assert List.keyfind(conn.resp_headers, "location", 0) ==
      {"location", "/users"}
    assert conn.status == 302
    assert conn.resp_cookies["access_token"]
  end

  test "login fails for incorrect password" do
    opts = {true, :cookie, {0, 1440}, :email, &DB.find_user/2}
    conn = call("ray@mail.com", "oohwhatwasitagain", "email", opts)
    assert List.keyfind(conn.resp_headers, "location", 0) ==
      {"location", "/login"}
    assert conn.status == 302
    refute conn.resp_cookies["access_token"]
  end

  test "login fails for invalid email" do
    opts = {true, :cookie, {0, 1440}, :email, &DB.find_user/2}
    conn = call("dick@mail.com", "hard2guess", "email", opts)
    assert List.keyfind(conn.resp_headers, "location", 0) ==
      {"location", "/login"}
    assert conn.status == 302
    refute conn.resp_cookies["access_token"]
  end

  test "multiple possible unique ids - email for email_username func" do
    opts = {true, :cookie, {0, 1440}, &LoginTools.email_username/1, &DB.find_user/2}
    conn = call("ray@mail.com", "hard2guess", "email", opts)
    assert List.keyfind(conn.resp_headers, "location", 0) ==
      {"location", "/users"}
    assert conn.status == 302
    assert conn.resp_cookies["access_token"]
  end

  test "multiple possible unique ids - username for email_username func" do
    opts = {true, :cookie, {0, 1440}, &LoginTools.email_username/1, &DB.find_user/2}
    conn = call("ray", "hard2guess", "email", opts)
    assert List.keyfind(conn.resp_headers, "location", 0) ==
      {"location", "/users"}
    assert conn.status == 302
    assert conn.resp_cookies["access_token"]
  end

  test "multiple possible unique ids - phone for phone_username func" do
    opts = {true, :cookie, {0, 1440}, &LoginTools.phone_username/1, &DB.find_user/2}
    conn = call("081555555", "hard2guess", "phone", opts)
    assert List.keyfind(conn.resp_headers, "location", 0) ==
      {"location", "/users"}
    assert conn.status == 302
    assert conn.resp_cookies["access_token"]
  end

  test "multiple possible unique ids - username for phone_username func" do
    opts = {true, :cookie, {0, 1440}, &LoginTools.phone_username/1, &DB.find_user/2}
    conn = call("ray", "hard2guess", "phone", opts)
    assert List.keyfind(conn.resp_headers, "location", 0) ==
      {"location", "/users"}
    assert conn.status == 302
    assert conn.resp_cookies["access_token"]
  end

  test "fail login with multiple possible unique ids - phone for phone_username func" do
    opts = {true, :cookie, {0, 1440}, &LoginTools.phone_username/1, &DB.find_user/2}
    conn = call("081555555", "oohwhatwasitagain", "phone", opts)
    assert List.keyfind(conn.resp_headers, "location", 0) ==
      {"location", "/login"}
    assert conn.status == 302
    refute conn.resp_cookies["access_token"]
  end

  test "fail login with multiple possible unique ids - username for phone_username func" do
    opts = {true, :cookie, {0, 1440}, &LoginTools.phone_username/1, &DB.find_user/2}
    conn = call("rav", "hard2guess", "phone", opts)
    assert List.keyfind(conn.resp_headers, "location", 0) ==
      {"location", "/login"}
    assert conn.status == 302
    refute conn.resp_cookies["access_token"]
  end

end
