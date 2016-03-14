defmodule Openmaize.LoginTest do
  use ExUnit.Case
  use Plug.Test

  alias Openmaize.{Login, Login.Name}

  def call(name, password, uniq, opts) do
    conn(:post, "/login",
         %{"user" => %{uniq => name, "password" => password}})
    |> Login.call(opts)
  end

  test "login succeeds with username" do
    opts = {:cookie, :username}
    conn = call("ray", "h4rd2gU3$$", "username", opts)
    assert conn.resp_cookies["access_token"]
  end

  test "login succeeds with email" do
    opts = {:cookie, :email}
    conn = call("ray@mail.com", "h4rd2gU3$$", "email", opts)
    assert conn.resp_cookies["access_token"]
  end

  test "login fails for incorrect password" do
    opts = {:cookie, :email}
    conn = call("ray@mail.com", "oohwhatwasitagain", "email", opts)
    refute conn.resp_cookies["access_token"]
  end

  test "login fails for invalid email" do
    opts = {:cookie, :email}
    conn = call("dick@mail.com", "h4rd2gU3$$", "email", opts)
    refute conn.resp_cookies["access_token"]
  end

  test "multiple possible unique ids - email for email_username func" do
    opts = {:cookie, &Name.email_username/1}
    conn = call("ray@mail.com", "h4rd2gU3$$", "email", opts)
    assert conn.resp_cookies["access_token"]
  end

  test "multiple possible unique ids - username for email_username func" do
    opts = {:cookie, &Name.email_username/1}
    conn = call("ray", "h4rd2gU3$$", "email", opts)
    assert conn.resp_cookies["access_token"]
  end

  test "multiple possible unique ids - phone for phone_username func" do
    opts = {:cookie, &Name.phone_username/1}
    conn = call("081555555", "h4rd2gU3$$", "phone", opts)
    assert conn.resp_cookies["access_token"]
  end

  test "multiple possible unique ids - username for phone_username func" do
    opts = {:cookie, &Name.phone_username/1}
    conn = call("ray", "h4rd2gU3$$", "phone", opts)
    assert conn.resp_cookies["access_token"]
  end

  test "fail login with multiple possible unique ids - phone for phone_username func" do
    opts = {:cookie, &Name.phone_username/1}
    conn = call("081555555", "oohwhatwasitagain", "phone", opts)
    refute conn.resp_cookies["access_token"]
  end

  test "fail login with multiple possible unique ids - username for phone_username func" do
    opts = {:cookie, &Name.phone_username/1}
    conn = call("rav", "h4rd2gU3$$", "phone", opts)
    refute conn.resp_cookies["access_token"]
  end

end
