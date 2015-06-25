defmodule Openmaize.TokenTest do
  use ExUnit.Case
  use Plug.Test

  alias Openmaize.Token

  test "token stored in cookie" do
    user = %{id: 1, name: "Raymond Luxury Yacht", role: "user"}
    conn = conn(:get, "/") |> Token.add_token(user, :cookie)
    token = conn.resp_cookies["access_token"]
    assert token.http_only == true
    assert List.keyfind(conn.resp_headers, "location", 0) ==
           {"location", "http://www.example.com/users"}
    assert conn.status == 302
  end

  test "token not stored in cookie" do
    user = %{id: 1, name: "Raymond Luxury Yacht", role: "user"}
    conn = conn(:get, "/") |> Token.add_token(user, nil)
    assert String.starts_with?(conn.resp_body, "{\"access_token\":")
    assert conn.status == 200
  end

end
