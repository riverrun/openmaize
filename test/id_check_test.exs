defmodule Openmaize.IdCheckTest do
  use ExUnit.Case
  use Plug.Test

  import Openmaize.IdCheck

  @user_token "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9." <>
  "eyJyb2xlIjoidXNlciIsIm5hbWUiOiJSYXltb25kIEx1eHVyeSBZYWNodCIsImlkIjoxfQ." <>
  "oeUo6ZWA2VlaqQQzMa1mqIeEJvaIZfsUrtulgjgzvjqTc4MVjKps3Tqwxdxi5GRYoUOMRGiQgnedOfc8islEnA"

  def noedit(conn) do
    conn |> Openmaize.call([check: &id_noedit/4])
  end

  def noshow(conn) do
    conn |> Openmaize.call([check: &id_noshow/4])
  end

  test "user with correct id can edit" do
    conn = conn(:get, "/users/1/edit") |> put_req_cookie("access_token", @user_token)
                                      |> noedit |> send_resp(200, "")
    assert conn.status == 200
    assert conn.assigns == %{current_user: %{id: 1, name: "Raymond Luxury Yacht", role: "user"}}
  end

  test "user with correct id can show" do
    conn = conn(:get, "/users/1") |> put_req_cookie("access_token", @user_token)
                                      |> noshow |> send_resp(200, "")
    assert conn.status == 200
    assert conn.assigns == %{current_user: %{id: 1, name: "Raymond Luxury Yacht", role: "user"}}
  end

  test "user with wrong id, but start of id is the same" do
    conn = conn(:get, "/users/10/edit") |> put_req_cookie("access_token", @user_token) |> noedit
    assert List.keyfind(conn.resp_headers, "location", 0) ==
           {"location", "http://www.example.com/users"}
    assert conn.status == 302
  end

  test "user with wrong id -- cannot edit" do
    conn = conn(:get, "/users/3/edit") |> put_req_cookie("access_token", @user_token) |> noedit
    assert List.keyfind(conn.resp_headers, "location", 0) ==
           {"location", "http://www.example.com/users"}
    assert conn.status == 302
  end

  test "user with wrong id -- cannot show" do
    conn = conn(:get, "/users/3") |> put_req_cookie("access_token", @user_token) |> noshow
    assert List.keyfind(conn.resp_headers, "location", 0) ==
           {"location", "http://www.example.com/users"}
    assert conn.status == 302
  end

end
