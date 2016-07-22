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
    assert OnetimePass.init([]) == {nil, []}
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

  test "raises error if no db_module is set" do
    user = %{"hotp" => "816065", "id" => "5"}
    assert_raise ArgumentError, "You need to set the db_module value for Openmaize.OnetimePass", fn ->
      call(user, {nil, []})
    end
  end

end
