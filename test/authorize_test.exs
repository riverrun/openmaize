defmodule Openmaize.AuthorizeTest do
  use ExUnit.Case
  use Plug.Test

  import Openmaize.AccessControl

  @admin %{id: 2, username: "Big Boss", role: "admin"}
  @user %{id: 1, username: "Raymond Luxury Yacht", role: "user"}

  def call(path, current_user, roles) do
    conn(:get, path)
    |> assign(:current_user, current_user)
    |> authorize(roles: roles)
  end

  test "correct token with role admin" do
    conn = call("/admin", @admin, ["admin"]) |> send_resp(200, "")
    refute conn.private[:openmaize_error]
    assert conn.status == 200
  end

  test "correct token with role user" do
    conn = call("/users", @user, ["user"]) |> send_resp(200, "")
    refute conn.private[:openmaize_error]
    assert conn.status == 200
  end

  test "no user error" do
    conn = call("/admin", nil, ["admin"])
    assert conn.private.openmaize_error =~ "You have to be logged in to view"
  end

  test "insufficient permissions" do
    conn = call("/admin", @admin, ["user"])
    assert conn.private.openmaize_error =~ "You do not have permission to view"
  end

  test "roles option not set" do
    assert_raise ArgumentError, fn ->
      call("/admin", @admin, [])
    end
  end

end
