defmodule Openmaize.TokenTest do
  use ExUnit.Case
  use Plug.Test

  import Openmaize.{Token, Token.Verify}

  @token_opts {0, 86400}

  test "token stored in cookie with redirects" do
    user = %{id: 1, name: "Raymond Luxury Yacht", role: "user"}
    conn = conn(:get, "/") |> add_token(user, {true, :cookie, @token_opts, :name})
    token = conn.resp_cookies["access_token"].value
    {:ok, data} = verify_token(token)
    assert data.name
    assert List.keyfind(conn.resp_headers, "location", 0) ==
           {"location", "/users"}
    assert conn.status == 302
  end

  test "token stored in cookie without redirects" do
    user = %{id: 1, name: "Raymond Luxury Yacht", role: "user"}
    conn = conn(:get, "/") |> add_token(user, {false, :cookie, @token_opts, :name})
    token = conn.resp_cookies["access_token"]
    assert token.http_only == true
    assert conn.status == 200
  end

  test "token not stored in cookie without redirects" do
    user = %{id: 1, name: "Raymond Luxury Yacht", role: "user"}
    conn = conn(:get, "/") |> add_token(user, {false, nil, @token_opts, :name})
    assert String.starts_with?(conn.resp_body, "{\"access_token\":")
    assert conn.status == 200
  end

  test "token with custom unique_id" do
    user = %{id: 1, email: "ray@mail.com", role: "user"}
    conn = conn(:get, "/") |> add_token(user, {true, :cookie, @token_opts, :email})
    token = conn.resp_cookies["access_token"].value
    {:ok, data} = verify_token(token)
    assert data.email
  end

end
