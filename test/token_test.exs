defmodule Sanction.TokenTest do
  use ExUnit.Case
  use Plug.Test

  alias Sanction.JWTAuthenticate
  alias Sanction.JWTAuthenticate.InvalidTokenError

  def call(conn, _opts) do
    conn
    |> JWTAuthenticate.call([])
    |> send_resp(200, "ok")
  end

  test "correct token" do
    token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6IlJheW1vbmQgTHV4dXJ5IFlhY2h0In0.BJKEQUKwAHsznCX9rF7138fUpu27NFFh4Sx8xFGYbF8"
    conn = conn(:get, "/") |> put_req_header("authorization", "Bearer #{token}") |> call([])
    assert conn.status == 200
    assert conn.assigns == %{authenticated_user: %{id: "Raymond Luxury Yacht"}}
  end

  test "error for missing token" do
    assert_raise InvalidTokenError, fn ->
      conn(:get, "/")
      |> call([])
    end
  end

end
