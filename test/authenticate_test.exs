defmodule Openmaize.AuthenticateTest do
  use ExUnit.Case
  use Plug.Test

  def call(conn) do
    conn |> Openmaize.call([]) |> send_resp(200, "")
  end

  test "correct token stored in cookie" do
    Application.put_env(:openmaize, :storage_method, "cookie")
    token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJuYW1lIjoiUmF5bW9uZCBMdXh1cnkgWWFjaHQifQ.hU4Mkca19Jr2OvkUMg52dMHUsaVJE-8VDGjVrDLUcdIsTDPUivSgiiiuKAHC93Xkrdog5yBAeVU8ZQ3V0QdbJw"
    conn = conn(:get, "/") |> put_req_cookie("access_token", token) |> call
    assert conn.status == 200
    assert conn.assigns == %{current_user: %{name: "Raymond Luxury Yacht"}}
  end

  test "redirect for invalid token stored in cookie" do
    Application.put_env(:openmaize, :storage_method, "cookie")
    token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJpZCI6IlJheW1vbmQgTHV4dXJ5IFlhY2h0In0.eIBGE2fWD8nU0WHuuh8skEG1R789FObmDRiHybI18oMfH1UPuzAuzwUE6P4eQakNIZPMFensifQLoD3r7kzR-Q"
    conn = conn(:get, "/") |> put_req_cookie("access_token", token) |> Openmaize.call([])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
           {"location", "http://www.example.com/admin/login"}
    assert conn.status == 301
  end

  test "correct token stored in sessionStorage" do
    Application.put_env(:openmaize, :storage_method, "sessionStorage")
    token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJuYW1lIjoiUmF5bW9uZCBMdXh1cnkgWWFjaHQifQ.hU4Mkca19Jr2OvkUMg52dMHUsaVJE-8VDGjVrDLUcdIsTDPUivSgiiiuKAHC93Xkrdog5yBAeVU8ZQ3V0QdbJw"
    conn = conn(:get, "/") |> put_req_header("authorization", "Bearer #{token}") |> call
    assert conn.status == 200
    assert conn.assigns == %{current_user: %{name: "Raymond Luxury Yacht"}}
  end

  test "redirect for invalid token stored in sessionStorage" do
    Application.put_env(:openmaize, :storage_method, "sessionStorage")
    token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJpZCI6IlJheW1vbmQgTHV4dXJ5IFlhY2h0In0.eIBGE2fWD8nU0WHuuh8skEG1R789FObmDRiHybI18oMfH1UPuzAuzwUE6P4eQakNIZPMFensifQLoD3r7kzR-Q"
    conn = conn(:get, "/") |> put_req_header("authorization", "Bearer #{token}") |> Openmaize.call([])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
           {"location", "http://www.example.com/admin/login"}
    assert conn.status == 301
  end

  test "correct token with id and role" do
    Application.put_env(:openmaize, :storage_method, "cookie")
    token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJyb2xlIjoiYWRtaW4iLCJuYW1lIjoiUmF5bW9uZCBMdXh1cnkgWWFjaHQifQ.y65Mw3fNLAt60IEugvqAMP236Sm3HE_kldT7TNjzmBD6Cu_C3DnYi1pDG7Pqa2THcSszwUrzC4xROOy_hAlqnQ"
    conn = conn(:get, "/") |> put_req_cookie("access_token", token) |> call
    assert conn.status == 200
    assert conn.assigns == %{current_user: %{name: "Raymond Luxury Yacht", role: "admin"}}
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
