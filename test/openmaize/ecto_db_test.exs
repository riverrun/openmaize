defmodule Openmaize.EctoDBTest do
  use ExUnit.Case
  use Plug.Test

  alias Openmaize.{EctoDB, DummyCrypto, TestRepo, TestUser}

  test "easy password results in an error being added to the changeset" do
    user = %{email: "bill@mail.com", username: "bill", role: "user", password: "easytoguess",
             phone: "081655555", confirmed_at: Ecto.DateTime.utc}
    {:error, changeset} = %TestUser{} |> TestUser.auth_changeset(user) |> TestRepo.insert
    errors = changeset.errors[:password] |> elem(0)
    assert errors =~ "password should contain at least one number"
  end

  test "add_confirm_token" do
    user = %TestUser{username: "bill", role: "user",
      confirmation_token: nil, confirmation_sent_at: nil}
    changeset = EctoDB.add_confirm_token(user, "lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw")
    assert changeset.changes.confirmation_token
    assert changeset.changes.confirmation_sent_at
  end

  test "add_reset_token" do
    user = %TestUser{email: "reg@mail.com", username: "reg", role: "user", password: "h4rd2gU3$$",
      phone: "081755555", confirmed_at: Ecto.DateTime.utc}
    changeset = EctoDB.add_reset_token(user, "lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw")
    assert changeset.changes.reset_token
    assert changeset.changes.reset_sent_at
  end

  test "check time" do
    assert EctoDB.check_time(Ecto.DateTime.utc, 60)
    refute EctoDB.check_time(Ecto.DateTime.utc, -60)
    refute EctoDB.check_time(nil, 60)
  end

  test "defaults to hashing password with bcrypt" do
    changeset = %TestUser{} |> TestUser.auth_changeset(%{password: "g0g0g4dg3t!!"})
    assert Comeonin.Bcrypt.checkpw("g0g0g4dg3t!!", changeset.changes.password_hash)
  end

  test "hashes according to algorithm" do
    Application.put_env(:openmaize, :crypto_mod, DummyCrypto)

    changeset = %TestUser{} |> TestUser.auth_changeset(%{password: "g0g0g4dg3t!!"})
    assert changeset.changes.password_hash == "dumb-g0g0g4dg3t!!-crypto"
  after
    Application.delete_env(:openmaize, :crypto_mod)
  end

end
