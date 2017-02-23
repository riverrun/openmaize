defmodule Openmaize.OnetimePassTest do
  use Openmaize.TestCase
  use Plug.Test

  import Ecto.Changeset
  alias Comeonin.Otp
  alias Openmaize.{OnetimePass, TestRepo, TestUser, UserHelpers}

  setup context do
    {:ok, %{id: user_id}} = UserHelpers.add_otp_user()
    otp_last = context[:last] || 0
    update_repo(user_id, otp_last)
    {:ok, %{user_id: user_id}}
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

  test "check hotp with default options", %{user_id: user_id} do
    user = %{"hotp" => "816065", "id" => user_id}
    conn = call(user, {TestRepo, TestUser, []})
    %{id: id, otp_last: otp_last} = conn.private[:openmaize_user]
    assert id == user_id
    assert otp_last == 2
    refute conn.private[:openmaize_error]
    fail = %{"hotp" => "816066", "id" => user_id}
    conn = call(fail, {TestRepo, TestUser, []})
    assert conn.private[:openmaize_error]
  end

  @tag last: 18
  test "check hotp with updated last", %{user_id: user_id} do
    user = %{"hotp" => "088239", "id" => user_id}
    conn = call(user, {TestRepo, TestUser, []})
    %{id: id, otp_last: otp_last} = conn.private[:openmaize_user]
    assert id == user_id
    assert otp_last == 19
    assert conn.private[:openmaize_user]
    refute conn.private[:openmaize_error]
    fail = %{"hotp" => "088238", "id" => user_id}
    conn = call(fail, {TestRepo, TestUser, []})
    assert conn.private[:openmaize_error]
  end

  test "check totp with default options", %{user_id: user_id} do
    token = Otp.gen_totp("MFRGGZDFMZTWQ2LK")
    user = %{"totp" => token, "id" => user_id}
    conn = call(user, {TestRepo, TestUser, []})
    assert conn.private[:openmaize_user]
    refute conn.private[:openmaize_error]
  end

  test "disallow totp check with same token", %{user_id: user_id} do
    token = Otp.gen_totp("MFRGGZDFMZTWQ2LK")
    user = %{"totp" => token, "id" => user_id}
    conn = call(user, {TestRepo, TestUser, []})
    %{otp_last: otp_last} = conn.private[:openmaize_user]
    update_repo(user_id, otp_last)
    conn = call(user, {TestRepo, TestUser, []})
    assert conn.private[:openmaize_error]
  end

  test "disallow totp check with earlier token that is still valid", %{user_id: user_id} do
    token = Otp.gen_totp("MFRGGZDFMZTWQ2LK")
    user = %{"totp" => token, "id" => user_id}
    conn = call(user, {TestRepo, TestUser, []})
    %{otp_last: otp_last} = conn.private[:openmaize_user]
    update_repo(user_id, otp_last)
    new_token = Otp.gen_hotp("MFRGGZDFMZTWQ2LK", otp_last - 1)
    user = %{"totp" => new_token, "id" => user_id}
    conn = call(user, {TestRepo, TestUser, []})
    assert conn.private[:openmaize_error]
  end

  test "output to current_user does not contain password_hash or otp_secret", %{user_id: user_id} do
    user = %{"hotp" => "816065", "id" => user_id}
    conn = call(user, {TestRepo, TestUser, []})
    user = conn.private[:openmaize_user]
    refute Map.has_key?(user, :password_hash)
    refute Map.has_key?(user, :otp_secret)
  end

end
