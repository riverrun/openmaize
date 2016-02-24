defmodule Openmaize.DBTest do
  use ExUnit.Case
  use Plug.Test

  alias Openmaize.{TestRepo, User}

  test "easy password results in an error being added to the changeset" do
    user = %{email: "bill@mail.com", username: "bill", role: "user", password: "easy2guess",
             phone: "081655555", confirmed_at: Ecto.DateTime.utc}
    {:error, changeset} = %User{} |> User.auth_changeset(user) |> TestRepo.insert
    assert changeset.errors[:password] =~ "password should contain at least one number"
  end

  test "add_confirm_token" do
  end

  test "add_reset_token" do
  end

  test "gen_token_link" do
  end

end
