defmodule Openmaize.AuthenticateTest do
  use ExUnit.Case
  use Plug.Test

  def call(conn) do
    conn |> Openmaize.call([]) |> send_resp(200, "")
  end

  test "correct token stored in cookie" do
    Application.put_env(:openmaize, :storage_method, "cookie")
    token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9." <>
    "eyJyb2xlIjoidXNlciIsIm5hbWUiOiJSYXltb25kIEx1eHVyeSBZYWNodCIsImlkIjoxfQ." <>
    "oeUo6ZWA2VlaqQQzMa1mqIeEJvaIZfsUrtulgjgzvjqTc4MVjKps3Tqwxdxi5GRYoUOMRGiQgnedOfc8islEnA"
    conn = conn(:get, "/") |> put_req_cookie("access_token", token) |> call
    assert conn.status == 200
    assert conn.assigns == %{current_user: %{id: 1, name: "Raymond Luxury Yacht", role: "user"}}
  end

  test "correct token with role admin stored in cookie" do
    Application.put_env(:openmaize, :storage_method, "cookie")
    token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9." <>
    "eyJyb2xlIjoiYWRtaW4iLCJuYW1lIjoiQmlnIEJvc3MiLCJpZCI6Mn0." <>
    "eCWmeWSs5vM9mxScrFoknZgcbW0Q8OMLzyHMyj7KKZI1mDD1N6cCY8laPYS0fK2v17DIvTQ-mZgDrezk9CGICw"
    conn = conn(:get, "/") |> put_req_cookie("access_token", token) |> call
    assert conn.status == 200
    assert conn.assigns == %{current_user: %{id: 2, name: "Big Boss", role: "admin"}}
  end

  test "redirect for invalid token stored in cookie" do
    Application.put_env(:openmaize, :storage_method, "cookie")
    token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9." <>
    "eyJpZCI6IlJheW1vbmQgTHV4dXJ5IFlhY2h0In0." <>
    "eIBGE2fWD8nU0WHuuh8skEG1R789FObmDRiHybI18oMfH1UPuzAuzwUE6P4eQakNIZPMFensifQLoD3r7kzR-Q"
    conn = conn(:get, "/") |> put_req_cookie("access_token", token) |> Openmaize.call([])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
           {"location", "http://www.example.com/admin/login"}
    assert conn.status == 301
  end

  test "correct token stored in sessionStorage" do
    Application.put_env(:openmaize, :storage_method, "sessionStorage")
    token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9." <>
    "eyJyb2xlIjoidXNlciIsIm5hbWUiOiJSYXltb25kIEx1eHVyeSBZYWNodCIsImlkIjoxfQ." <>
    "oeUo6ZWA2VlaqQQzMa1mqIeEJvaIZfsUrtulgjgzvjqTc4MVjKps3Tqwxdxi5GRYoUOMRGiQgnedOfc8islEnA"
    conn = conn(:get, "/") |> put_req_header("authorization", "Bearer #{token}") |> call
    assert conn.status == 200
    assert conn.assigns ==  %{current_user: %{id: 1, name: "Raymond Luxury Yacht", role: "user"}}
  end

  test "redirect for invalid token stored in sessionStorage" do
    Application.put_env(:openmaize, :storage_method, "sessionStorage")
    token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9." <>
    "eyJpZCI6IlJheW1vbmQgTHV4dXJ5IFlhY2h0In0." <>
    "eIBGE2fWD8nU0WHuuh8skEG1R789FObmDRiHybI18oMfH1UPuzAuzwUE6P4eQakNIZPMFensifQLoD3r7kzR-Q"
    conn = conn(:get, "/") |> put_req_header("authorization", "Bearer #{token}") |> Openmaize.call([])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
           {"location", "http://www.example.com/admin/login"}
    assert conn.status == 301
  end

  test "redirect for missing token" do
    conn = conn(:get, "/admin") |> Openmaize.call([])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
           {"location", "http://www.example.com/admin/login"}
    assert conn.status == 301
  end

  test "missing token for unprotected page" do
    conn = conn(:get, "/") |> call
    assert conn.status == 200
    assert conn.assigns == %{current_user: nil}
  end
end
