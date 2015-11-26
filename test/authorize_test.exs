defmodule Openmaize.AuthorizeTest do
  use ExUnit.Case
  use Plug.Test

  alias Openmaize.Authorize
  alias Openmaize.Authorize.Base

  @admin %{id: 2, name: "Big Boss", role: "admin"}
  @user %{id: 1, name: "Raymond Luxury Yacht", role: "user"}

  test "correct token with role admin" do
    conn = conn(:get, "/admin")
            |> assign(:current_user, @admin)
            |> Authorize.call([])
            |> send_resp(200, "")
    assert conn.status == 200
  end

  test "redirect for insufficient permissions" do
    conn = conn(:get, "/admin")
            |> assign(:current_user, @user)
            |> Authorize.call([])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
           {"location", "/users"}
    assert conn.status == 302
  end

  test "able to view user page as user" do
    conn = conn(:get, "/users")
            |> assign(:current_user, @user)
            |> Authorize.call([])
            |> send_resp(200, "")
    assert conn.status == 200
  end

  test "Base authorized? ok conn" do
    conn = Base.authorized?({:ok, :nomatch}, conn(:get, "/"), []) |> send_resp(200, "")
    assert conn.status == 200
    conn = Base.authorized?({:ok, "/users", "/users"}, conn(:get, "/"), []) |> send_resp(200, "")
    assert conn.status == 200
  end

  test "Base authorized? send_error 401" do
    conn = Base.authorized?({:error, "You have 10 minutes to spend it"},
    conn(:get, "/admin"), {false, false})
    assert conn.status == 401
  end

  test "Base authorized? send_error 403" do
    conn = Base.authorized?({:error, "user", "You have 10 minutes to spend it"},
    conn(:get, "/admin"), {false, false})
    assert conn.status == 403
  end

  test "Base authorized? handle_error with no role" do
    conn = Base.authorized?({:error, "You have 10 minutes to spend it"},
    conn(:get, "/admin"), {true, false})
    assert List.keyfind(conn.resp_headers, "location", 0) ==
           {"location", "/admin/login"}
    assert conn.status == 302
  end

  test "Base authorized? handle_error with role" do
    conn = Base.authorized?({:error, "user", "You have 10 minutes to spend it"},
    conn(:get, "/admin"), {true, false})
    assert List.keyfind(conn.resp_headers, "location", 0) ==
           {"location", "/users"}
    assert conn.status == 302
  end

end
