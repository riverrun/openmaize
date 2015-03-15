defmodule SanctionTest do
  use ExUnit.Case
  use Plug.Test

  alias Sanction.JWTAuthenticate
  alias Sanction.JWTAuthenticate.InvalidTokenError

  test "correct token" do
    token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6IlJheW1vbmQgTHV4dXJ5IFlhY2h0In0.BJKEQUKwAHsznCX9rF7138fUpu27NFFh4Sx8xFGYbF8"
    conn = conn(:get, "/") |> put_req_header("authorization", token) |> JWTAuthenticate.call([])
    assert conn.status == 200
  end

  test "error for missing token" do
    assert_raise InvalidTokenError, fn ->
      conn(:get, "/")
      |> JWTAuthenticate.call([])
    end
  end

end
