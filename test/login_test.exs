defmodule Openmaize.LoginTest do
  use ExUnit.Case
  use Plug.Test

  alias Openmaize.{DummyCrypto, TestRepo, TestUser}

  def login(name, password, uniq \\ :username, user_params \\ "username") do
    conn(:post, "/login",
         %{"session" => %{user_params => name, "password" => password}})
    |> Openmaize.Login.call({uniq, user_params, TestRepo, TestUser})
  end

  def phone_name(%{"username" => username, "password" => password}) do
    {Regex.match?(~r/^[0-9]+$/, username) and :phone || :username, username, password}
  end

  test "init function" do
    assert Openmaize.Login.init([]) == {:username, "username", Openmaize.Repo, Openmaize.User}
  end

  test "login succeeds with username" do
    conn = login("ray", "h4rd2gU3$$")
    %{id: id} = conn.private[:openmaize_user]
    assert id == 4
  end

  test "login succeeds with email" do
    conn = login("ray@mail.com", "h4rd2gU3$$", :email, "email")
    %{id: id} = conn.private[:openmaize_user]
    assert id == 4
  end

  test "login fails when crypto mod changes" do
    Application.put_env(:openmaize, :crypto_mod, DummyCrypto)
    conn = login("ray", "h4rd2gU3$$")
    assert conn.private[:openmaize_error]
  after
    Application.delete_env(:openmaize, :crypto_mod)
  end

  test "login fails for incorrect password" do
    conn = login("ray", "oohwhatwasitagain")
    assert conn.private[:openmaize_error] =~ "Invalid credentials"
  end

  test "login fails when account is not yet confirmed" do
    conn = login("fred", "mangoes&g0oseberries")
    assert conn.private[:openmaize_error] =~ "have to confirm your account"
  end

  test "login fails for invalid username" do
    conn = login("dick", "h4rd2gU3$$")
    assert conn.private[:openmaize_error] =~ "Invalid credentials"
  end

  test "login fails for invalid email" do
    conn = login("dick@mail.com", "h4rd2gU3$$", :email, "email")
    assert conn.private[:openmaize_error] =~ "Invalid credentials"
  end

  test "function unique_id with username" do
    conn = login("ray", "h4rd2gU3$$", &phone_name/1, "username")
    %{id: id} = conn.private[:openmaize_user]
    assert id == 4
  end

  test "function unique_id with phone" do
    conn = login("081555555", "h4rd2gU3$$", &phone_name/1, "username")
    %{id: id} = conn.private[:openmaize_user]
    assert id == 4
  end

  test "output to current_user does not contain password_hash or otp_secret" do
    conn = login("ray", "h4rd2gU3$$")
    user = conn.private[:openmaize_user]
    refute Map.has_key?(user, :password_hash)
    refute Map.has_key?(user, :otp_secret)
  end

end
