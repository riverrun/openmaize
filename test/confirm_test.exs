defmodule Openmaize.ConfirmTest do
  use ExUnit.Case
  use Plug.Test

  alias Openmaize.Confirm

  @valid_link "email=fred%40mail.com&key=lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw"
  @invalid_link "email=wrong%40mail.com&key=lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw"
  @key "lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw"

  def call(link, opts) do
    conn(:get, "/confirm?" <> link)
    |> fetch_query_params
    |> Confirm.user_email(opts)
  end

  def custom_query("fred@mail.com", :email) do
    %{email: "fred@mail.com", role: "user", confirmed: false,
      confirmation_token: "lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw"}
  end
  def custom_query("wrong@mail.com", :email) do
    %{email: "wrong@mail.com", role: "user", confirmed: false,
      confirmation_token: "LG9UXGNMpb5LUGEDm62PrwW8c20qZmIw"}
  end

  def custom_send(email) do
    IO.puts "#{email}"
  end

  test "Confirmation fails for invalid token" do
    conn = call(@invalid_link, [query_function: &custom_query/2, valid_email: &custom_send/1])
    assert conn.halted == true
  end


end
