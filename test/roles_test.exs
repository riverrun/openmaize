defmodule Openmaize.RolesTest do
  use ExUnit.Case
  use Plug.Test

  @admin_token "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9." <>
  "eyJyb2xlIjoiYWRtaW4iLCJuYW1lIjoiQmlnIEJvc3MiLCJpZCI6Mn0." <>
  "eCWmeWSs5vM9mxScrFoknZgcbW0Q8OMLzyHMyj7KKZI1mDD1N6cCY8laPYS0fK2v17DIvTQ-mZgDrezk9CGICw"

  @user_token "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9." <>
  "eyJyb2xlIjoidXNlciIsIm5hbWUiOiJSYXltb25kIEx1eHVyeSBZYWNodCIsImlkIjoxfQ." <>
  "oeUo6ZWA2VlaqQQzMa1mqIeEJvaIZfsUrtulgjgzvjqTc4MVjKps3Tqwxdxi5GRYoUOMRGiQgnedOfc8islEnA"

  def call(conn) do
    conn |> Openmaize.call([]) |> send_resp(200, "")
  end

  test "correct token with role admin" do
    conn = conn(:get, "/admin") |> put_req_cookie("access_token", @admin_token) |> call
    assert conn.status == 200
    assert conn.assigns == %{current_user: %{id: 2, name: "Big Boss", role: "admin"}}
  end

  test "redirect for insufficient permissions" do
    conn = conn(:get, "/admin") |> put_req_cookie("access_token", @user_token) |> Openmaize.call([])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
           {"location", "http://www.example.com/users"}
    assert conn.status == 302
  end

  test "able to view other user's page" do
    conn = conn(:get, "/users/3") |> put_req_cookie("access_token", @user_token) |> call
    assert conn.status == 200
    assert conn.assigns == %{current_user: %{id: 1, name: "Raymond Luxury Yacht", role: "user"}}
  end

  test "main user page" do
    conn = conn(:get, "/users") |> put_req_cookie("access_token", @user_token) |> call
    assert conn.status == 200
    assert conn.assigns == %{current_user: %{id: 1, name: "Raymond Luxury Yacht", role: "user"}}
  end

end
