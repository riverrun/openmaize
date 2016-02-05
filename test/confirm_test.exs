defmodule Openmaize.ConfirmTest do
  use ExUnit.Case
  use Plug.Test

  alias Openmaize.Confirm

  @valid_link "email=fred%40mail.com&key=lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw"
  @invalid_link "email=wrong%40mail.com&key=lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw"
  @incomplete_link "email=wrong%40mail.com"

  @valid_user %{email: "fred@mail.com", confirmed: false,
    confirmation_sent_at: Ecto.DateTime.utc,
    confirmation_token: "lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw"}
  @invalid_user %{email: "wrong@mail.com", confirmed: false,
    confirmation_sent_at: Ecto.DateTime.utc,
    confirmation_token: "LG9UXGNMpb5LUGEDm62PrwW8c20qZmIw"}

  def call(link, opts) do
    conn(:get, "/confirm?" <> link)
    |> fetch_query_params
    |> Confirm.user_email(opts)
  end

  def custom_query("fred@mail.com", :email) do
    @valid_user
  end
  def custom_query("wrong@mail.com", :email) do
    @invalid_user
  end

  test "Confirmation succeeds for valid token" do
    #Application.put_env(:openmaize, :repo, @valid_user)
    #{:ok, user, email} = call(@valid_link, [query_function: &custom_query/2])
    #assert user.confirmed == true
    #assert email == "fred@mail.com"
  end

  test "Confirmation fails for invalid token" do
    result = call(@invalid_link, [query_function: &custom_query/2])
    assert result == {:error, "Confirmation for wrong@mail.com failed"}
  end

  test "Confirmation fails for expired token" do
    result = call(@valid_link, [query_function: &custom_query/2, key_expires_after: 0])
    assert result == {:error, "Confirmation for fred@mail.com failed"}
  end

  test "Invalid link error" do
    result = call(@incomplete_link, [query_function: &custom_query/2])
    assert result == {:error, "Invalid link"}
  end

end
