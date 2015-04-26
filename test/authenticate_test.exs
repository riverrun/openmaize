defmodule Sanction.AuthenticateTest do
  use ExUnit.Case
  use Plug.Test

  alias Sanction.Authenticate

  def call(conn, _opts) do
    conn
    |> Authenticate.call([])
    |> send_resp(200, "ok")
  end

  test "correct token stored in cookie" do
    Application.put_env(:sanction, :storage_method, "cookie")
    token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJpZCI6IlJheW1vbmQgTHV4dXJ5IFlhY2h0In0.L4J3kHwl3K5LqAOVqTGskzsUuDsv-rf0xhkSS9g6gYL_SlD7BOYLghItE1U-jHAHpuNnmhlvmmyW4hAIKMgGkw"
    conn = conn(:get, "/") |> put_req_cookie("access_token", token) |> Authenticate.call([]) |> send_resp(200, "ok")
    assert conn.status == 200
    assert conn.assigns == %{authenticated_user: %{id: "Raymond Luxury Yacht"}}
  end

  test "redirect for invalid token stored in cookie" do
    Application.put_env(:sanction, :storage_method, "cookie")
    Application.put_env(:sanction, :login_page, "https://example.com/users/login")
    token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJpZCI6IlJheW1vbmQgTHV4dXJ5IFlhY2h0In0.eIBGE2fWD8nU0WHuuh8skEG1R789FObmDRiHybI18oMfH1UPuzAuzwUE6P4eQakNIZPMFensifQLoD3r7kzR-Q"
    conn = conn(:get, "/") |> put_req_cookie("access_token", token) |> Authenticate.call([])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
           {"location", "https://example.com/users/login"}
    assert conn.status == 301
  end

  test "correct token stored in sessionStorage" do
    Application.put_env(:sanction, :storage_method, "sessionStorage")
    token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJpZCI6IlJheW1vbmQgTHV4dXJ5IFlhY2h0In0.L4J3kHwl3K5LqAOVqTGskzsUuDsv-rf0xhkSS9g6gYL_SlD7BOYLghItE1U-jHAHpuNnmhlvmmyW4hAIKMgGkw"
    conn = conn(:get, "/") |> put_req_header("authorization", "Bearer #{token}") |> Authenticate.call([]) |> send_resp(200, "ok")
    assert conn.status == 200
    assert conn.assigns == %{authenticated_user: %{id: "Raymond Luxury Yacht"}}
  end

  test "redirect for invalid token stored in sessionStorage" do
    Application.put_env(:sanction, :storage_method, "sessionStorage")
    Application.put_env(:sanction, :login_page, "https://example.com/users/login")
    token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJpZCI6IlJheW1vbmQgTHV4dXJ5IFlhY2h0In0.eIBGE2fWD8nU0WHuuh8skEG1R789FObmDRiHybI18oMfH1UPuzAuzwUE6P4eQakNIZPMFensifQLoD3r7kzR-Q"
    conn = conn(:get, "/") |> put_req_header("authorization", "Bearer #{token}") |> Authenticate.call([])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
           {"location", "https://example.com/users/login"}
    assert conn.status == 301
  end

  test "correct token with id and role" do
    Application.put_env(:sanction, :storage_method, "cookie")
    token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJyb2xlIjoiYWRtaW4iLCJpZCI6IlJheW1vbmQgTHV4dXJ5IFlhY2h0In0.ld_sq2pMcQI6lrGT9LGDe59ApE1pOlBjvy0odq789wSaeXfOrH4dbACPLA6LDo8w_B-yXL6Gd49-5_KlcNbbcQ"
    conn = conn(:get, "/") |> put_req_cookie("access_token", token) |> Authenticate.call([]) |> send_resp(200, "ok")
    assert conn.status == 200
    assert conn.assigns == %{authenticated_user: %{id: "Raymond Luxury Yacht", role: "admin"}}
  end

  test "redirect for missing token" do
    Application.put_env(:sanction, :login_page, "https://example.com/users/login")
    conn = conn(:get, "/") |> Authenticate.call([])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
           {"location", "https://example.com/users/login"}
    assert conn.status == 301
  end
end
