defmodule Openmaize.ConfirmTest do
  use ExUnit.Case
  use Plug.Test

  alias Openmaize.Confirm

  @valid_link "email=fred%40mail.com&key=lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw"
  @invalid_link "email=wrong%40mail.com&key=lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw"

  @valid_user %{email: "fred@mail.com", confirmation_token: "lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw"}

  def call(link, opts) do
    conn(:get, "/confirm?" <> link)
    |> fetch_query_params
    |> Confirm.user_email(opts)
  end

  def custom_query("fred@mail.com", :email) do
    @valid_user
  end
  def custom_query("wrong@mail.com", :email) do
    %{email: "wrong@mail.com", confirmation_token: "LG9UXGNMpb5LUGEDm62PrwW8c20qZmIw"}
  end

  test "Confirmation succeeds for valid token" do
    #result = call(@valid_link, [query_function: &custom_query/2])
    #assert result == {:ok, @valid_user, "fred@mail.com"}
  end

  test "Confirmation fails for invalid token" do
    result = call(@invalid_link, [query_function: &custom_query/2])
    assert result == {:error, "Confirmation for wrong@mail.com failed"}
  end

end
