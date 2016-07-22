defmodule Openmaize.ConfirmEmailTest do
  use ExUnit.Case
  use Plug.Test

  import Ecto.Changeset
  alias Openmaize.{ConfirmEmail, EctoDB, TestRepo, TestUser}

  @valid_link "email=fred%2B1%40mail.com&key=lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw"
  @name_link "username=fred&key=lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw"
  @invalid_link "email=wrong%40mail.com&key=lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw"
  @incomplete_link "email=wrong%40mail.com"

  setup do
    {:ok, _user} = TestRepo.get_by(TestUser, email: "fred+1@mail.com")
    |> change(%{confirmed_at: nil})
    |> Openmaize.TestRepo.update
    :ok
  end

  def call_confirm(link, opts) do
    conn(:get, "/confirm?" <> link)
    |> fetch_query_params
    |> ConfirmEmail.call(opts)
  end

  def user_confirmed do
    user = TestRepo.get_by(TestUser, email: "fred+1@mail.com")
    user.confirmed_at
  end

  test "init function" do
    assert ConfirmEmail.init([]) == {nil, {60, :email, nil}}
  end

  test "confirmation succeeds for valid token" do
    conn = call_confirm(@valid_link, {EctoDB, {120, :email, nil}})
    assert user_confirmed()
    assert conn.private.openmaize_info =~ "Account successfully confirmed"
  end

  test "confirmation fails for invalid token" do
    conn = call_confirm(@invalid_link, {EctoDB, {120, :email, nil}})
    refute user_confirmed()
    assert conn.private.openmaize_error =~ "Confirmation for"
  end

  test "confirmation fails for expired token" do
    conn = call_confirm(@valid_link, {EctoDB, {0, :email, nil}})
    refute user_confirmed()
    assert conn.private.openmaize_error =~ "Confirmation for"
  end

  test "invalid link error" do
    conn = call_confirm(@incomplete_link, {EctoDB, {120, :email, nil}})
    refute user_confirmed()
    assert conn.private.openmaize_error =~ "Invalid link"
  end

  test "confirmation succeeds with different unique id" do
    conn = call_confirm(@name_link, {EctoDB, {120, :username, nil}})
    assert user_confirmed()
    assert conn.private.openmaize_info =~ "Account successfully confirmed"
  end

  test "confirmation fails when query fails" do
    conn = call_confirm("key=lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw", {EctoDB, {120, :email, nil}})
    refute user_confirmed()
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

  test "raises error if no db_module is set" do
    assert_raise ArgumentError, "You need to set the db_module value for Openmaize.ConfirmEmail", fn ->
      call_confirm(@valid_link, {nil, {120, :email, nil}})
    end
  end

end
