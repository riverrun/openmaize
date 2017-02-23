defmodule Openmaize.UserHelpers do

  alias Openmaize.{TestRepo, TestUser}

  def add_user do
    user = %{email: "fred+1@mail.com", username: "fred", role: "user", password: "mangoes&g0oseberries",
      confirmed_at: nil, confirmation_sent_at: Ecto.DateTime.utc, reset_sent_at: Ecto.DateTime.utc}
    %TestUser{}
    |> TestUser.confirm_changeset(user, "lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw")
    |> TestRepo.insert
  end

  def add_confirmed do
    user = %{email: "ray@mail.com", username: "ray", role: "user", password: "h4rd2gU3$$",
      phone: "081555555", confirmed_at: Ecto.DateTime.utc}
    %TestUser{} |> TestUser.auth_changeset(user) |> TestRepo.insert
  end

  def add_wrong_user do
    user = %{email: "wrong@mail.com", role: "user", password: "mangoes&g0oseberries",
      confirmed_at: nil, confirmation_sent_at: Ecto.DateTime.utc}
    %TestUser{}
    |> TestUser.confirm_changeset(user, "LG9UXGNMpb5LUGEDm62PrwW8c20qZmIw")
    |> TestRepo.insert
  end

  def add_otp_user do
    user = %{email: "brian@mail.com", username: "brian", role: "user", password: "h4rd2gU3$$",
      otp_required: true, otp_secret: "MFRGGZDFMZTWQ2LK", otp_last: 0}
    %TestUser{} |> TestUser.auth_changeset(user) |> TestRepo.insert
  end

  def add_reset_user(key) do
    user = %{email: "frank@mail.com", username: "frank", role: "user", password: "h4rd2gU3$$",
      phone: "081555557", confirmed_at: Ecto.DateTime.utc}
    %TestUser{}
    |> TestUser.auth_changeset(user)
    |> Openmaize.Database.add_reset_token(key)
    |> TestRepo.insert
  end
end
