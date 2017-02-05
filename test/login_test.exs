defmodule Openmaize.LoginTest do
  use ExUnit.Case
  use Plug.Test

  alias Openmaize.{DummyCrypto, Login, TestRepo, TestUser}

  def call(name, password, uniq, opts) do
    conn(:post, "/login",
         %{"session" => %{uniq => name, "password" => password}})
    |> Login.call(opts)
  end

  test "init function" do
    assert Login.init([]) == {Openmaize.Repo, Openmaize.User}
  end

  test "login succeeds with username" do
    opts = {TestRepo, TestUser}
    conn = call("ray", "h4rd2gU3$$", "username", opts)
    %{id: id, role: role} = conn.private[:openmaize_user]
    assert id == 4
    assert role == "user"
  end

  test "login succeeds with email" do
    opts = {TestRepo, TestUser}
    conn = call("ray@mail.com", "h4rd2gU3$$", "email", opts)
    %{id: id, role: role} = conn.private[:openmaize_user]
    assert id == 4
    assert role == "user"
  end

  test "login fails when crypto mod changes" do
    Application.put_env(:openmaize, :crypto_mod, DummyCrypto)
    opts = {TestRepo, TestUser}
    conn = call("ray@mail.com", "h4rd2gU3$$", "email", opts)
    assert conn.private[:openmaize_error]
  after
    Application.delete_env(:openmaize, :crypto_mod)
  end

  test "login fails for incorrect password" do
    opts = {TestRepo, TestUser}
    conn = call("ray@mail.com", "oohwhatwasitagain", "email", opts)
    assert conn.private[:openmaize_error]
  end

  test "login fails for invalid email" do
    opts = {TestRepo, TestUser}
    conn = call("dick@mail.com", "h4rd2gU3$$", "email", opts)
    assert conn.private[:openmaize_error]
  end

  test "error raised for incorrect params" do
    opts = {TestRepo, TestUser}
    assert_raise ArgumentError, "invalid params or options", fn ->
      call("081555555", "h4rd2gU3$$", "phone", opts)
    end
  end

end
