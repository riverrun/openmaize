defmodule Openmaize.LogoutTest do
  use ExUnit.Case
  use Plug.Test

  import Openmaize.Token.Create
  alias Openmaize.Logout

  setup_all do
    {:ok, user_token} = %{id: 1, name: "Raymond Luxury Yacht", role: "user"}
    |> generate_token(:name, {0, 86400})

    {:ok, %{user_token: user_token}}
  end

  def call(token, :cookie, redirects) do
    conn(:get, "/logout")
    |> put_req_cookie("access_token", token)
    |> fetch_cookies
    |> Logout.call(redirects)
  end

  def call(token, _) do
    conn(:get, "/logout")
    |> put_req_header("authorization", "Bearer #{token}")
    |> Logout.call(false)
  end

  test "logout with cookie and redirect", %{user_token: user_token} do
    conn = call(user_token, :cookie, true)
    assert conn.resp_cookies["access_token"] ==
      %{max_age: 0, universal_time: {{1970, 1, 1}, {0, 0, 0}}}
    assert List.keyfind(conn.resp_headers, "location", 0) ==
           {"location", "/"}
    assert conn.halted == true
    assert conn.status == 302
  end

  test "logout with redirect to login page", %{user_token: user_token} do
    Application.put_env(:openmaize, :redirect_pages, %{"logout" => "/login"})
    conn = call(user_token, :cookie, true)
    assert List.keyfind(conn.resp_headers, "location", 0) ==
           {"location", "/login"}
    assert conn.halted == true
    assert conn.status == 302
    Application.put_env(:openmaize, :redirect_pages,
                        %{"admin" => "/admin", "user" => "/users"})
  end

  test "logout with cookie and without redirect", %{user_token: user_token} do
    conn = call(user_token, :cookie, false)
    assert conn.resp_cookies["access_token"] ==
      %{max_age: 0, universal_time: {{1970, 1, 1}, {0, 0, 0}}}
    assert conn.halted == true
  end

  test "logout with storage nil and without redirect", %{user_token: user_token} do
    conn = call(user_token, nil)
    refute conn.resp_cookies["access_token"]
    assert conn.halted == true
  end

end
