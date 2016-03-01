defmodule Openmaize.LoginTest do
  use ExUnit.Case
  use Plug.Test

  alias Openmaize.{Login, Login.Name, TestRepo, User}

  setup_all do
    user = %{email: "ray@mail.com", username: "ray", role: "user", password: "h4rd2gU3$$",
            phone: "081555555", confirmed_at: Ecto.DateTime.utc}
    {:ok, _} = %User{} |> User.auth_changeset(user) |> TestRepo.insert

    :ok
  end

  def call(name, password, uniq, opts) do
    conn(:post, "/login",
         %{"user" => %{uniq => name, "password" => password}})
    |> Login.call(opts)
  end

  def redirected(conn, path) do
    assert List.keyfind(conn.resp_headers, "location", 0) ==
      {"location", path}
    assert conn.status == 302
  end

  test "login succeeds with username" do
    opts = {true, :cookie, :username}
    conn = call("ray", "h4rd2gU3$$", "username", opts)
    redirected(conn, "/users")
    assert conn.resp_cookies["access_token"]
  end

  test "login succeeds with email" do
    opts = {true, :cookie, :email}
    conn = call("ray@mail.com", "h4rd2gU3$$", "email", opts)
    redirected(conn, "/users")
    assert conn.resp_cookies["access_token"]
  end

  test "login fails for incorrect password" do
    opts = {true, :cookie, :email}
    conn = call("ray@mail.com", "oohwhatwasitagain", "email", opts)
    redirected(conn, "/login")
    refute conn.resp_cookies["access_token"]
  end

  test "login fails for invalid email" do
    opts = {true, :cookie, :email}
    conn = call("dick@mail.com", "h4rd2gU3$$", "email", opts)
    redirected(conn, "/login")
    refute conn.resp_cookies["access_token"]
  end

  test "multiple possible unique ids - email for email_username func" do
    opts = {true, :cookie, &Name.email_username/1}
    conn = call("ray@mail.com", "h4rd2gU3$$", "email", opts)
    redirected(conn, "/users")
    assert conn.resp_cookies["access_token"]
  end

  test "multiple possible unique ids - username for email_username func" do
    opts = {true, :cookie, &Name.email_username/1}
    conn = call("ray", "h4rd2gU3$$", "email", opts)
    redirected(conn, "/users")
    assert conn.resp_cookies["access_token"]
  end

  test "multiple possible unique ids - phone for phone_username func" do
    opts = {true, :cookie, &Name.phone_username/1}
    conn = call("081555555", "h4rd2gU3$$", "phone", opts)
    redirected(conn, "/users")
    assert conn.resp_cookies["access_token"]
  end

  test "multiple possible unique ids - username for phone_username func" do
    opts = {true, :cookie, &Name.phone_username/1}
    conn = call("ray", "h4rd2gU3$$", "phone", opts)
    redirected(conn, "/users")
    assert conn.resp_cookies["access_token"]
  end

  test "fail login with multiple possible unique ids - phone for phone_username func" do
    opts = {true, :cookie, &Name.phone_username/1}
    conn = call("081555555", "oohwhatwasitagain", "phone", opts)
    redirected(conn, "/login")
    refute conn.resp_cookies["access_token"]
  end

  test "fail login with multiple possible unique ids - username for phone_username func" do
    opts = {true, :cookie, &Name.phone_username/1}
    conn = call("rav", "h4rd2gU3$$", "phone", opts)
    redirected(conn, "/login")
    refute conn.resp_cookies["access_token"]
  end

end
