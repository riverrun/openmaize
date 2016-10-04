defmodule Openmaize.OnetimePassTest do
  use ExUnit.Case
  use Plug.Test

  alias Comeonin.Otp
  alias Openmaize.{EctoDB, OnetimePass}

  def get_count do
    {megasecs, secs, _} = :os.timestamp()
    trunc((megasecs * 1000000 + secs) / 30)
  end

  def call(user, opts) do
    conn(:post, "/twofactor", %{"user" => user})
    |> OnetimePass.call(opts)
  end

  test "init function" do
    assert OnetimePass.init([]) == {Openmaize.OpenmaizeEcto, []}
  end

  test "check hotp with default options" do
    user = %{"hotp" => "816065", "id" => "5"}
    conn = call(user, {EctoDB, []})
    %{id: id, role: role, last: last} = conn.private[:openmaize_user]
    assert id == 5
    assert role == "user"
    assert last == 2
    refute conn.private[:openmaize_error]
    fail = %{"hotp" => "816066", "id" => "5"}
    conn = call(fail, {EctoDB, []})
    assert conn.private[:openmaize_error]
  end

  test "check hotp with last option" do
    user = %{"hotp" => "088239", "id" => "5"}
    conn = call(user, {EctoDB, [last: 18]})
    %{id: id, role: role, last: last} = conn.private[:openmaize_user]
    assert id == 5
    assert role == "user"
    assert last == 19
    assert conn.private[:openmaize_user]
    refute conn.private[:openmaize_error]
    fail = %{"hotp" => "088238", "id" => "5"}
    conn = call(fail, {EctoDB, [last: 18]})
    assert conn.private[:openmaize_error]
  end

  test "check totp with default options" do
    token = Otp.gen_totp("MFRGGZDFMZTWQ2LK")
    user = %{"totp" => token, "id" => "5"}
    conn = call(user, {EctoDB, []})
    assert conn.private[:openmaize_user]
    refute conn.private[:openmaize_error]
  end

 test "check if multiple logins, near in time and with the same totp, will fail when the configuration parameter 'allow_multiple_otp_logins' is set to false" do
    alias Openmaize.{TestRepo, TestUser}

    # Bypass the app configuration for this test. Doesn't allow multiple logins
    Application.put_env(:openmaize, :allow_multiple_otp_logins, false)

    # Obtain the totp token for the given user id
    # (user id 6 has been setted with 'admin' role, so the two factor authentication is mandatory)
    id = 6
    test_user = TestRepo.get(TestUser, id)
    totp_token = Comeonin.Otp.gen_totp(test_user.otp_secret)

    # Setup user params for the twofactor post call
    user = %{"id" => Integer.to_string(id), "totp" => totp_token}
    
    # Try first two factor login (will succeed)
    conn = call(user, {EctoDB, []})
    assert conn.private[:openmaize_user]

    # Try the second two factor login with the same totp as before (will fail)
    conn = call(user, {EctoDB, []})
    refute conn.private[:openmaize_error] != "Invalid credentials"
 end

  test "check if multiple logins, near in time and with the same totp, will succeed when the configuration parameter 'allow_multiple_otp_logins' is set to true" do
    alias Openmaize.{TestRepo, TestUser}

    # Bypass the app configuration for this test. Allow multiple logins
    Application.put_env(:openmaize, :allow_multiple_otp_logins, true)

    # Obtain the totp token for the given user id
    # (user id 6 has been setted with 'admin' role, so the two factor authentication is mandatory)
    id = 6
    test_user = TestRepo.get(TestUser, id)
    totp_token = Comeonin.Otp.gen_totp(test_user.otp_secret)

    # Setup user params for the twofactor post call
    user = %{"id" => Integer.to_string(id), "totp" => totp_token}
    
    # Try first two factor login (will succeed)
    conn = call(user, {EctoDB, []})
    assert conn.private[:openmaize_user]

    # Try the second two factor login with the same totp as before (will fail)
    conn = call(user, {EctoDB, []})
    assert conn.private[:openmaize_user]
 end

end
