defmodule Openmaize.LoginTest do
  use ExUnit.Case
  use Plug.Test

  alias Openmaize.{DummyCrypto, TestRepo, TestUser}

  @opts {TestRepo, TestUser}

  def login_name(name, password, user_id \\ "username") do
    conn(:post, "/login",
         %{"session" => %{user_id => name, "password" => password}})
    |> Openmaize.Login.call(@opts)
  end

  def login_email(name, password) do
    conn(:post, "/login",
         %{"session" => %{"email" => name, "password" => password}})
    |> Openmaize.EmailLogin.call(@opts)
  end

  test "init function" do
    assert Openmaize.Login.init([]) == {Openmaize.Repo, Openmaize.User}
  end

  test "login succeeds with username" do
    conn = login_name("ray", "h4rd2gU3$$")
    %{id: id, role: role} = conn.private[:openmaize_user]
    assert id == 4
    assert role == "user"
  end

  test "login succeeds with email" do
    conn = login_email("ray@mail.com", "h4rd2gU3$$")
    %{id: id, role: role} = conn.private[:openmaize_user]
    assert id == 4
    assert role == "user"
  end

  test "login fails when crypto mod changes" do
    Application.put_env(:openmaize, :crypto_mod, DummyCrypto)
    conn = login_name("ray", "h4rd2gU3$$")
    assert conn.private[:openmaize_error]
  after
    Application.delete_env(:openmaize, :crypto_mod)
  end

  test "login fails for incorrect password" do
    conn = login_name("ray", "oohwhatwasitagain")
    assert conn.private[:openmaize_error] =~ "Invalid credentials"
  end

  test "login fails when account is not yet confirmed" do
    conn = login_name("fred", "mangoes&g0oseberries")
    assert conn.private[:openmaize_error] =~ "have to confirm your account"
  end

  test "login fails for invalid username" do
    conn = login_name("dick", "h4rd2gU3$$")
    assert conn.private[:openmaize_error] =~ "Invalid credentials"
  end

  test "login fails for invalid email" do
    conn = login_email("dick@mail.com", "h4rd2gU3$$")
    assert conn.private[:openmaize_error] =~ "Invalid credentials"
  end

  test "error raised for incorrect params" do
    assert_raise ArgumentError, "invalid params or options", fn ->
      login_name("081555555", "h4rd2gU3$$", "phone")
    end
  end

end
