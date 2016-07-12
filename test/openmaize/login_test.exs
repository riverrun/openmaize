defmodule Openmaize.LoginTest do
  use ExUnit.Case
  use Plug.Test

  alias Openmaize.{DummyCrypto, EctoDB, Login, Login.Name, SessionHelper}

  def call(name, password, uniq, opts) do
    conn(:post, "/login",
         %{"user" => %{uniq => name, "password" => password}})
    |> SessionHelper.sign_conn
    |> Login.call(opts)
  end

  test "init function" do
    assert Login.init([]) == {nil, :username}
  end

  test "login succeeds with username" do
    opts = {EctoDB, :username}
    conn = call("ray", "h4rd2gU3$$", "username", opts)
    assert conn.private[:openmaize_user] == %{id: 4, role: "user"}
    assert get_session(conn, :user_id) == 4
  end

  test "login succeeds with email" do
    opts = {EctoDB, :email}
    conn = call("ray@mail.com", "h4rd2gU3$$", "email", opts)
    assert conn.private[:openmaize_user] == %{id: 4, role: "user"}
    assert get_session(conn, :user_id) == 4
  end

  test "login fails when crypto mod changes" do
    Application.put_env(:openmaize, :crypto_mod, DummyCrypto)
    opts = {EctoDB, :email}
    conn = call("ray@mail.com", "h4rd2gU3$$", "email", opts)
    refute get_session(conn, :user_id)
    assert conn.private[:openmaize_error]
  after
    Application.delete_env(:openmaize, :crypto_mod)
  end

  test "login fails for incorrect password" do
    opts = {EctoDB, :email}
    conn = call("ray@mail.com", "oohwhatwasitagain", "email", opts)
    refute get_session(conn, :user_id)
    assert conn.private[:openmaize_error]
  end

  test "login fails for invalid email" do
    opts = {EctoDB, :email}
    conn = call("dick@mail.com", "h4rd2gU3$$", "email", opts)
    refute get_session(conn, :user_id)
    assert conn.private[:openmaize_error]
  end

  test "multiple possible unique ids - email for email_username func" do
    opts = {EctoDB, &Name.email_username/1}
    conn = call("ray@mail.com", "h4rd2gU3$$", "email", opts)
    assert conn.private[:openmaize_user] == %{id: 4, role: "user"}
    assert get_session(conn, :user_id) == 4
  end

  test "multiple possible unique ids - username for email_username func" do
    opts = {EctoDB, &Name.email_username/1}
    conn = call("ray", "h4rd2gU3$$", "email", opts)
    assert conn.private[:openmaize_user] == %{id: 4, role: "user"}
    assert get_session(conn, :user_id) == 4
  end

  test "multiple possible unique ids - phone for phone_username func" do
    opts = {EctoDB, &Name.phone_username/1}
    conn = call("081555555", "h4rd2gU3$$", "phone", opts)
    assert conn.private[:openmaize_user] == %{id: 4, role: "user"}
    assert get_session(conn, :user_id) == 4
  end

  test "multiple possible unique ids - username for phone_username func" do
    opts = {EctoDB, &Name.phone_username/1}
    conn = call("ray", "h4rd2gU3$$", "phone", opts)
    assert conn.private[:openmaize_user] == %{id: 4, role: "user"}
    assert get_session(conn, :user_id) == 4
  end

  test "fail login with multiple possible unique ids - phone for phone_username func" do
    opts = {EctoDB, &Name.phone_username/1}
    conn = call("081555555", "oohwhatwasitagain", "phone", opts)
    refute get_session(conn, :user_id)
    assert conn.private[:openmaize_error]
  end

  test "fail login with multiple possible unique ids - username for phone_username func" do
    opts = {EctoDB, &Name.phone_username/1}
    conn = call("rav", "h4rd2gU3$$", "phone", opts)
    refute get_session(conn, :user_id)
    assert conn.private[:openmaize_error]
  end

  test "raises error if no db_module is set" do
    opts = {nil, :email}
    assert_raise ArgumentError, "You need to set the db_module value for Openmaize.Login", fn ->
      call("ray@mail.com", "h4rd2gU3$$", "email", opts)
    end
  end

end
