defmodule Openmaize.AuthenticateTest do
  use ExUnit.Case
  use Plug.Test

  import Openmaize.Token.Create
  alias Openmaize.Authenticate

  setup_all do
    {:ok, user_token} = %{id: 1, name: "Raymond Luxury Yacht", role: "user"}
    |> generate_token({-10, 86400})

    {:ok, exp_token} = %{id: 1, name: "Raymond Luxury Yacht", role: "user"}
    |> generate_token({-10, 0})

    {:ok, %{user_token: user_token, invalid_token: user_token <> "a", exp_token: exp_token}}
  end

  def call(conn, opts \\ []) do
    conn |> Authenticate.call(opts) |> send_resp(200, "")
  end

  test "redirect for expired token", %{exp_token: exp_token} do
    conn = conn(:get, "/admin")
    |> put_req_cookie("access_token", exp_token)
    |> Authenticate.call([])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
      {"location", "http://www.example.com/admin/login"}
    assert conn.status == 302
  end

  test "correct token stored in cookie", %{user_token: user_token} do
    conn = conn(:get, "/")
    |> put_req_cookie("access_token", user_token)
    |> call
    assert conn.status == 200
    assert conn.assigns == %{current_user: %{id: 1, name: "Raymond Luxury Yacht", role: "user"}}
  end

  test "redirect for invalid token stored in cookie", %{invalid_token: invalid_token} do
    conn = conn(:get, "/")
    |> put_req_cookie("access_token", invalid_token)
    |> Authenticate.call([])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
      {"location", "http://www.example.com/admin/login"}
    assert conn.status == 302
  end

  test "correct token stored in sessionStorage", %{user_token: user_token} do
    conn = conn(:get, "/")
    |> put_req_header("authorization", "Bearer #{user_token}")
    |> call([storage: nil])
    assert conn.status == 200
    assert conn.assigns ==  %{current_user: %{id: 1, name: "Raymond Luxury Yacht", role: "user"}}
  end

  test "redirect for invalid token stored in sessionStorage", %{invalid_token: invalid_token} do
    conn = conn(:get, "/")
    |> put_req_header("authorization", "Bearer #{invalid_token}")
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
