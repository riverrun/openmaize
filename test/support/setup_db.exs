defmodule Openmaize.SetupDB do

  alias Openmaize.{TestRepo, User}

  def add_users do
    user1 = %{email: "fred@mail.com", username: "fred", role: "user", password: "mangoes&g0oseberries",
              confirmed_at: nil, confirmation_sent_at: Ecto.DateTime.utc, reset_sent_at: Ecto.DateTime.utc}
    user2 = %{email: "dim@mail.com", username: "dim", role: "user", password: "mangoes&g0oseberries",
              confirmed_at: nil, confirmation_sent_at: Ecto.DateTime.utc, reset_sent_at: Ecto.DateTime.utc}
    user3 = %{email: "wrong@mail.com", role: "user", password: "mangoes&g0oseberries",
              confirmed_at: nil, confirmation_sent_at: Ecto.DateTime.utc}

    {:ok, _} = %User{}
    |> User.confirm_changeset(user1, "lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw")
    |> TestRepo.insert
    {:ok, _} = %User{}
    |> User.confirm_changeset(user2, "lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw")
    |> TestRepo.insert
    {:ok, _} = %User{}
    |> User.confirm_changeset(user3, "LG9UXGNMpb5LUGEDm62PrwW8c20qZmIw")
    |> TestRepo.insert

    user4 = %{email: "ray@mail.com", username: "ray", role: "user", password: "h4rd2gU3$$",
              phone: "081555555", confirmed_at: Ecto.DateTime.utc, otp_secret: "MFRGGZDFMZTWQ2LK"}
    {:ok, _} = %User{} |> User.auth_changeset(user4) |> TestRepo.insert
  end

end
