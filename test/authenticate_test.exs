defmodule Openmaize.AuthenticateTest do
  use ExUnit.Case
  use Plug.Test

  import Openmaize.Token.Create
  alias Openmaize.Authenticate

  setup_all do
    {:ok, user_token} = %{id: 1, name: "Raymond Luxury Yacht", role: "user"}
    |> generate_token({0, 86400})

    {:ok, exp_token} = %{id: 1, name: "Raymond Luxury Yacht", role: "user"}
    |> generate_token({0, 0})

    Application.put_env(:openmaize, :token_alg, :sha256)
    {:ok, user_256_token} = %{id: 1, name: "Raymond Luxury Yacht", role: "user"}
    |> generate_token({0, 86400})
    Application.delete_env(:openmaize, :token_alg)

    {:ok, %{user_token: user_token, exp_token: exp_token, user_256_token: user_256_token}}
  end

  def call(url, token, storage) when storage == :cookie do
    conn(:get, url) |> put_req_cookie("access_token", token) |> Authenticate.call([])
  end

  def call(url, token, _) do
    conn(:get, url) |> put_req_header("authorization", "Bearer #{token}")
    |> Authenticate.call([storage: nil])
  end

  test "redirect for expired token", %{exp_token: exp_token} do
    conn = call("/admin", exp_token, :cookie)
    assert List.keyfind(conn.resp_headers, "location", 0) ==
      {"location", "http://www.example.com/admin/login"}
    assert conn.status == 302
  end

  test "correct token stored in cookie", %{user_token: user_token} do
    conn = call("/", user_token, :cookie) |> send_resp(200, "")
    assert conn.status == 200
    assert conn.assigns == %{current_user: %{id: 1, name: "Raymond Luxury Yacht", role: "user"}}
  end

  test "redirect for invalid token stored in cookie", %{user_token: user_token} do
    conn = call("/users", user_token <> "a", :cookie)
    assert List.keyfind(conn.resp_headers, "location", 0) ==
      {"location", "http://www.example.com/admin/login"}
    assert conn.status == 302
  end

  test "correct token stored in sessionStorage", %{user_token: user_token} do
    conn = call("/", user_token, :session) |> send_resp(200, "")
    assert conn.status == 200
    assert conn.assigns ==  %{current_user: %{id: 1, name: "Raymond Luxury Yacht", role: "user"}}
  end

  test "redirect for invalid token stored in sessionStorage", %{user_token: user_token} do
    conn = call("/users", user_token <> "a", :session)
    assert List.keyfind(conn.resp_headers, "location", 0) ==
      {"location", "http://www.example.com/admin/login"}
    assert conn.status == 302
  end

  test "invalid token for unprotected page", %{user_token: user_token} do
    conn = call("/", user_token <> "a", :cookie) |> send_resp(200, "")
    assert conn.status == 200
    assert conn.assigns ==  %{current_user: nil}
  end

  test "missing token" do
    conn = conn(:get, "/") |> Authenticate.call([]) |> send_resp(200, "")
    assert conn.status == 200
    assert conn.assigns == %{current_user: nil}
  end

  test "correct token using sha256", %{user_256_token: user_256_token} do
    conn = call("/", user_256_token, :cookie) |> send_resp(200, "")
    assert conn.status == 200
    assert conn.assigns == %{current_user: %{id: 1, name: "Raymond Luxury Yacht", role: "user"}}
  end

  test "redirect for invalid token using sha256", %{user_256_token: user_256_token} do
    conn = call("/users", user_256_token <> "a", :cookie)
    assert List.keyfind(conn.resp_headers, "location", 0) ==
      {"location", "http://www.example.com/admin/login"}
    assert conn.status == 302
  end

end
