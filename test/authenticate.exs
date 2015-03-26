defmodule Sanction.TokenTest do
  use ExUnit.Case
  use Plug.Test

  alias Sanction.Authenticate
  alias Sanction.Authenticate.InvalidTokenError

  def call(conn, _opts) do
    conn
    |> Authenticate.call([])
    |> send_resp(200, "ok")
  end

  test "correct token" do
    token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IlJheW1vbmQgTHV4dXJ5IFlhY2h0In0.5oz-tn0euVGSyZts2gDMAJohu2vfQeqrUisfpNE4kW4"
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
