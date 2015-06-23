defmodule Openmaize.AuthenticateTest do
  use ExUnit.Case
  use Plug.Test

  alias Openmaize.Authenticate

  @user_token "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9." <>
  "eyJyb2xlIjoidXNlciIsIm5hbWUiOiJSYXltb25kIEx1eHVyeSBZYWNodCIsImlkIjoxfQ." <>
  "oeUo6ZWA2VlaqQQzMa1mqIeEJvaIZfsUrtulgjgzvjqTc4MVjKps3Tqwxdxi5GRYoUOMRGiQgnedOfc8islEnA"

  @invalid "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9." <>
  "eyJpZCI6IlJheW1vbmQgTHV4dXJ5IFlhY2h0In0." <>
  "eIBGE2fWD8nU0WHuuh8skEG1R789FObmDRiHybI18oMfH1UPuzAuzwUE6P4eQakNIZPMFensifQLoD3r7kzR-Q"

  def call(conn, opts \\ []) do
    conn |> Authenticate.call(opts) |> send_resp(200, "")
  end

  test "redirect for expired token" do
    expired_token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9." <>
    "eyJyb2xlIjoidXNlciIsIm5hbWUiOiJSYXltb25kIEx1eHVyeSBZYWNodCIsImlkIjoxLCJleHAiOjE0MzM5Mjk1MTF9." <>
    "k3VN9SAbbV1SP8eNx_j1GHMxp3CeL_J4fEyEuU6Y80bvLAoAv_3CN47J5DrHnyYyqTSiMhVRTCKgrOSyamE4RQ"
    conn = conn(:get, "/admin")
            |> put_req_cookie("access_token", expired_token)
            |> Authenticate.call([])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
           {"location", "http://www.example.com/admin/login"}
    assert conn.status == 302
  end

  test "correct token stored in cookie" do
    conn = conn(:get, "/")
            |> put_req_cookie("access_token", @user_token)
            |> call
    assert conn.status == 200
    assert conn.assigns == %{current_user: %{id: 1, name: "Raymond Luxury Yacht", role: "user"}}
  end

  test "redirect for invalid token stored in cookie" do
    conn = conn(:get, "/")
            |> put_req_cookie("access_token", @invalid)
            |> Authenticate.call([])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
           {"location", "http://www.example.com/admin/login"}
    assert conn.status == 302
  end

  test "correct token stored in sessionStorage" do
    conn = conn(:get, "/")
            |> put_req_header("authorization", "Bearer #{@user_token}")
            |> call([storage: nil])
    assert conn.status == 200
    assert conn.assigns ==  %{current_user: %{id: 1, name: "Raymond Luxury Yacht", role: "user"}}
  end

  test "redirect for invalid token stored in sessionStorage" do
    conn = conn(:get, "/")
            |> put_req_header("authorization", "Bearer #{@invalid}")
            |> Authenticate.call([storage: nil])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
           {"location", "http://www.example.com/admin/login"}
    assert conn.status == 302
  end

  test "missing token" do
    conn = conn(:get, "/") |> call
    assert conn.status == 200
    assert conn.assigns == %{current_user: nil}
  end
end
