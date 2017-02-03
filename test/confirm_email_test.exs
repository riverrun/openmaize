defmodule Openmaize.ConfirmEmailTest do
  use ExUnit.Case
  use Plug.Test

  import Ecto.Changeset
  alias Openmaize.{ConfirmEmail, TestRepo, TestUser}

  @valid_link "email=fred%2B1%40mail.com&key=lg8UXGNMpb5LUGEDm62PrwW8c20qZmIw"
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
    assert ConfirmEmail.init([]) == {Openmaize.Repo, Openmaize.User, {60, &IO.puts/1}}
  end

  test "confirmation succeeds for valid token" do
    conn = call_confirm(@valid_link, {TestRepo, TestUser, {120, &IO.puts/1}})
    assert user_confirmed()
    assert conn.private.openmaize_info =~ "Account successfully confirmed"
  end

  test "confirmation fails for invalid token" do
    conn = call_confirm(@invalid_link, {TestRepo, TestUser, {120, &IO.puts/1}})
    refute user_confirmed()
    assert conn.private.openmaize_error =~ "Confirmation for"
  end

  test "confirmation fails for expired token" do
    conn = call_confirm(@valid_link, {TestRepo, TestUser, {0, &IO.puts/1}})
    refute user_confirmed()
    assert conn.private.openmaize_error =~ "Confirmation for"
  end

  test "invalid link error" do
    conn = call_confirm(@incomplete_link, {TestRepo, TestUser, {120, &IO.puts/1}})
    refute user_confirmed()
    assert conn.private.openmaize_error =~ "Invalid link"
  end

  test "confirmation fails for already confirmed account" do
    call_confirm(@valid_link, {TestRepo, TestUser, {120, &IO.puts/1}})
    conn = call_confirm(@valid_link, {TestRepo, TestUser, {120, &IO.puts/1}})
    assert user_confirmed()
    assert conn.private.openmaize_error =~ "User account already confirmed"
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
