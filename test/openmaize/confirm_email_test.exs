defmodule Openmaize.ConfirmEmailTest do
  use ExUnit.Case
  use Plug.Test

  import Ecto.Changeset
  alias Openmaize.{ConfirmEmail, TestRepo, User}

  @valid_link "email=fred%2B1%40mail.com&key=lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw"
  @name_link "username=fred&key=lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw"
  @invalid_link "email=wrong%40mail.com&key=lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw"
  @incomplete_link "email=wrong%40mail.com"

  setup do
    {:ok, _user} = TestRepo.get_by(User, email: "fred+1@mail.com")
    |> change(%{confirmed_at: nil})
    |> Openmaize.Config.repo.update
    :ok
  end

  def call_confirm(link, opts) do
    conn(:get, "/confirm?" <> link)
    |> fetch_query_params
    |> ConfirmEmail.call(opts)
  end

  def user_confirmed do
    user = TestRepo.get_by(User, email: "fred+1@mail.com")
    user.confirmed_at
  end

  test "confirmation succeeds for valid token" do
    conn = call_confirm(@valid_link, {120, :email, nil})
    assert user_confirmed
    assert conn.private.openmaize_info =~ "Account successfully confirmed"
  end

  test "confirmation fails for invalid token" do
    conn = call_confirm(@invalid_link, {120, :email, nil})
    refute user_confirmed
    assert conn.private.openmaize_error =~ "Confirmation for"
  end

  test "confirmation fails for expired token" do
    conn = call_confirm(@valid_link, {0, :email, nil})
    refute user_confirmed
    assert conn.private.openmaize_error =~ "Confirmation for"
  end

  test "invalid link error" do
    conn = call_confirm(@incomplete_link, {120, :email, nil})
    refute user_confirmed
    assert conn.private.openmaize_error =~ "Invalid link"
  end

  test "confirmation succeeds with different unique id" do
    conn = call_confirm(@name_link, {120, :username, nil})
    assert user_confirmed
    assert conn.private.openmaize_info =~ "Account successfully confirmed"
  end

  test "confirmation fails when query fails" do
    conn = call_confirm("key=lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw", {120, :email, nil})
    refute user_confirmed
    assert conn.private.openmaize_error =~ "Confirmation for"
  end

  test "gen_token_link" do
    {key, link} = ConfirmEmail.gen_token_link("fred@mail.com")
    assert link =~ "email=fred%40mail.com&key="
    assert :binary.match(link, [key]) == {26, 32}
  end

  test "gen_token_link with custom unique_id" do
    {key, link} = ConfirmEmail.gen_token_link("fred", :username)
    assert link =~ "username=fred&key="
    assert :binary.match(link, [key]) == {18, 32}
  end

end
