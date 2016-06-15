defmodule Openmaize.LoginTest do
  use ExUnit.Case
  use Plug.Test

  alias Openmaize.{Login, Login.Name}
  alias OpenmaizeJWT.{Tools, Verify}

  def call(name, password, uniq, opts) do
    conn(:post, "/login",
         %{"user" => %{uniq => name, "password" => password}})
    |> Login.call(opts)
  end

  test "login succeeds with username" do
    opts = {:cookie, :username, &OpenmaizeJWT.Plug.add_token/5, nil}
    conn = call("ray", "h4rd2gU3$$", "username", opts)
    assert conn.resp_cookies["access_token"]
    refute conn.private[:openmaize_error]
    assert conn.private[:openmaize_user]
  end

  test "login succeeds with email" do
    opts = {:cookie, :email, &OpenmaizeJWT.Plug.add_token/5, nil}
    conn = call("ray@mail.com", "h4rd2gU3$$", "email", opts)
    assert conn.resp_cookies["access_token"]
    refute conn.private[:openmaize_error]
    assert conn.private[:openmaize_user]
  end

  test "login fails for incorrect password" do
    opts = {:cookie, :email, &OpenmaizeJWT.Plug.add_token/5, nil}
    conn = call("ray@mail.com", "oohwhatwasitagain", "email", opts)
    refute conn.resp_cookies["access_token"]
    assert conn.private[:openmaize_error]
    refute conn.private[:openmaize_user]
  end

  test "login fails for invalid email" do
    opts = {:cookie, :email, &OpenmaizeJWT.Plug.add_token/5, nil}
    conn = call("dick@mail.com", "h4rd2gU3$$", "email", opts)
    refute conn.resp_cookies["access_token"]
    assert conn.private[:openmaize_error]
    refute conn.private[:openmaize_user]
  end

  test "multiple possible unique ids - email for email_username func" do
    opts = {:cookie, &Name.email_username/1, &OpenmaizeJWT.Plug.add_token/5, nil}
    conn = call("ray@mail.com", "h4rd2gU3$$", "email", opts)
    assert conn.resp_cookies["access_token"]
    refute conn.private[:openmaize_error]
    assert conn.private[:openmaize_user]
  end

  test "multiple possible unique ids - username for email_username func" do
    opts = {:cookie, &Name.email_username/1, &OpenmaizeJWT.Plug.add_token/5, nil}
    conn = call("ray", "h4rd2gU3$$", "email", opts)
    assert conn.resp_cookies["access_token"]
    refute conn.private[:openmaize_error]
    assert conn.private[:openmaize_user]
  end

  test "multiple possible unique ids - phone for phone_username func" do
    opts = {:cookie, &Name.phone_username/1, &OpenmaizeJWT.Plug.add_token/5, nil}
    conn = call("081555555", "h4rd2gU3$$", "phone", opts)
    assert conn.resp_cookies["access_token"]
    refute conn.private[:openmaize_error]
    assert conn.private[:openmaize_user]
  end

  test "multiple possible unique ids - username for phone_username func" do
    opts = {:cookie, &Name.phone_username/1, &OpenmaizeJWT.Plug.add_token/5, nil}
    conn = call("ray", "h4rd2gU3$$", "phone", opts)
    assert conn.resp_cookies["access_token"]
    refute conn.private[:openmaize_error]
    assert conn.private[:openmaize_user]
  end

  test "fail login with multiple possible unique ids - phone for phone_username func" do
    opts = {:cookie, &Name.phone_username/1, &OpenmaizeJWT.Plug.add_token/5, nil}
    conn = call("081555555", "oohwhatwasitagain", "phone", opts)
    refute conn.resp_cookies["access_token"]
    assert conn.private[:openmaize_error]
    refute conn.private[:openmaize_user]
  end

  test "fail login with multiple possible unique ids - username for phone_username func" do
    opts = {:cookie, &Name.phone_username/1, &OpenmaizeJWT.Plug.add_token/5, nil}
    conn = call("rav", "h4rd2gU3$$", "phone", opts)
    refute conn.resp_cookies["access_token"]
    assert conn.private[:openmaize_error]
    refute conn.private[:openmaize_user]
  end

  test "override default token validity, remember me example" do
    opts = {:cookie, :username, &OpenmaizeJWT.Plug.add_token/5, 10_080}
    conn = conn(:post, "/login", %{"user" => %{"username" => "ray",
       "password" => "h4rd2gU3$$", "remember_me" => true}}) |> Login.call(opts)
    token = conn.resp_cookies["access_token"]
    assert token.max_age == 604_800
    {:ok, %{exp: exp}} = Verify.verify_token token.value
    assert exp - Tools.current_time > 500_000_000
  end

  test "remember me set to false example" do
    opts = {:cookie, :username, &OpenmaizeJWT.Plug.add_token/5, 10_080}
    conn = conn(:post, "/login", %{"user" => %{"username" => "ray",
       "password" => "h4rd2gU3$$", "remember_me" => false}}) |> Login.call(opts)
    token = conn.resp_cookies["access_token"]
    assert token.max_age == 7200
    {:ok, %{exp: exp}} = Verify.verify_token token.value
    assert exp - Tools.current_time < 8_000_000
  end

end
