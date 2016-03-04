defmodule Openmaize.AuthorizeTest do
  use ExUnit.Case
  use Plug.Test

  alias Openmaize.Authorize

  @admin %{id: 2, username: "Big Boss", role: "admin"}
  @user %{id: 1, username: "Raymond Luxury Yacht", role: "user"}

  def call(path, current_user, roles, redirects \\ true) do
    conn(:get, path)
    |> assign(:current_user, current_user)
    |> Authorize.call({roles, redirects})
  end

  test "correct token with role admin" do
    conn = call("/admin", @admin, ["admin"]) |> send_resp(200, "")
    assert conn.status == 200
  end

  test "correct token with role user" do
    conn = call("/users", @user, ["user"]) |> send_resp(200, "")
    assert conn.status == 200
  end

  test "redirect for insufficient permissions" do
    conn = call("/admin", @user, ["admin"])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
           {"location", "/users"}
    assert conn.status == 302
  end

  test "redirect for no user" do
    conn = call("/admin", nil, ["admin", "user"])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
           {"location", "/login"}
    assert conn.status == 302
  end

  test "redirect to custom login page for no user" do
    Application.put_env(:openmaize, :redirect_pages, %{"login" => "/admin/login"})
    conn = call("/admin", nil, ["admin", "user"])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
      {"location", "/admin/login"}
    assert conn.status == 302
    Application.put_env(:openmaize, :redirect_pages,
                        %{"admin" => "/admin", "user" => "/users"})
  end

  test "no user with no redirect" do
    conn = call("/admin", nil, ["admin"], false)
    assert conn.status == 401
  end

  test "insufficient permissions with no redirect" do
    conn = call("/admin", @admin, ["user"], false)
    assert conn.status == 403
  end

  test "roles option not set" do
    assert_raise ArgumentError, fn ->
      call("/admin", @admin, [])
    end
  end

end
