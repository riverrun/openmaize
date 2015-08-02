defmodule Openmaize.AuthorizeTest do
  use ExUnit.Case
  use Plug.Test

  alias Openmaize.Authorize

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
           {"location", "http://www.example.com/users"}
    assert conn.status == 302
  end

  test "able to view user page as user" do
    conn = conn(:get, "/users")
            |> assign(:current_user, @user)
            |> Authorize.call([])
            |> send_resp(200, "")
    assert conn.status == 200
  end

end
