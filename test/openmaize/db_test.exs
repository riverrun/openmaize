defmodule Openmaize.DBTest do
  use ExUnit.Case
  use Plug.Test

  alias Openmaize.{DB, TestRepo, User}

  test "easy password results in an error being added to the changeset" do
    user = %{email: "bill@mail.com", username: "bill", role: "user", password: "easytoguess",
             phone: "081655555", confirmed_at: Ecto.DateTime.utc}
    {:error, changeset} = %User{} |> User.auth_changeset(user) |> TestRepo.insert
    assert changeset.errors[:password] =~ "password should contain at least one number"
  end

  test "add_confirm_token" do
    user = Map.merge(%User{},
                     %{username: "bill", role: "user",
                       confirmation_token: nil, confirmation_sent_at: nil})
    changeset = DB.add_confirm_token(user, "lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw")
    assert changeset.changes.confirmation_token
    assert changeset.changes.confirmation_sent_at
  end

  test "add_reset_token" do
    user = Map.merge(%User{},
                     %{email: "reg@mail.com", username: "reg", role: "user", password: "h4rd2gU3$$",
                       phone: "081755555", confirmed_at: Ecto.DateTime.utc})
    changeset = DB.add_reset_token(user, "lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw")
    assert changeset.changes.reset_token
    assert changeset.changes.reset_sent_at
  end

end
