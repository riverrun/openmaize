defmodule Openmaize.OnetimePassTest do
  use ExUnit.Case
  use Plug.Test

  import Ecto.Changeset
  alias Comeonin.Otp
  alias Openmaize.{OnetimePass, TestRepo, TestUser}

  setup context do
    otp_last = context[:last] || 0
    update_repo(5, otp_last)
    on_exit fn -> update_repo(5, 0) end
    :ok
  end

  def call(user, opts) do
    conn(:post, "/twofactor", %{"user" => user})
    |> OnetimePass.call(opts)
  end

  def update_repo(user_id, otp_last) do
    TestRepo.get(TestUser, user_id)
    |> change(%{otp_last: otp_last})
    |> TestRepo.update!
  end

  test "init function" do
    assert OnetimePass.init([]) == {Openmaize.Repo, Openmaize.User, []}
  end

  test "check hotp with default options" do
    user = %{"hotp" => "816065", "id" => "5"}
    conn = call(user, {TestRepo, TestUser, []})
    %{id: id, otp_last: otp_last} = conn.private[:openmaize_user]
    assert id == 5
    assert otp_last == 2
    refute conn.private[:openmaize_error]
    fail = %{"hotp" => "816066", "id" => "5"}
    conn = call(fail, {TestRepo, TestUser, []})
    assert conn.private[:openmaize_error]
  end

  @tag last: 18
  test "check hotp with updated last" do
    user = %{"hotp" => "088239", "id" => "5"}
    conn = call(user, {TestRepo, TestUser, []})
    %{id: id, otp_last: otp_last} = conn.private[:openmaize_user]
    assert id == 5
    assert otp_last == 19
    assert conn.private[:openmaize_user]
    refute conn.private[:openmaize_error]
    fail = %{"hotp" => "088238", "id" => "5"}
    conn = call(fail, {TestRepo, TestUser, []})
    assert conn.private[:openmaize_error]
  end

  test "check totp with default options" do
    token = Otp.gen_totp("MFRGGZDFMZTWQ2LK")
    user = %{"totp" => token, "id" => "5"}
    conn = call(user, {TestRepo, TestUser, []})
    assert conn.private[:openmaize_user]
    refute conn.private[:openmaize_error]
  end

  test "disallow totp check with same token" do
    token = Otp.gen_totp("MFRGGZDFMZTWQ2LK")
    user = %{"totp" => token, "id" => "5"}
    conn = call(user, {TestRepo, TestUser, []})
    %{otp_last: otp_last} = conn.private[:openmaize_user]
    update_repo(5, otp_last)
    conn = call(user, {TestRepo, TestUser, []})
    assert conn.private[:openmaize_error]
  end

  test "disallow totp check with earlier token that is still valid" do
    token = Otp.gen_totp("MFRGGZDFMZTWQ2LK")
    user = %{"totp" => token, "id" => "5"}
    conn = call(user, {TestRepo, TestUser, []})
    %{otp_last: otp_last} = conn.private[:openmaize_user]
    update_repo(5, otp_last)
    new_token = Otp.gen_hotp("MFRGGZDFMZTWQ2LK", otp_last - 1)
    user = %{"totp" => new_token, "id" => "5"}
    conn = call(user, {TestRepo, TestUser, []})
    assert conn.private[:openmaize_error]
  end

end
