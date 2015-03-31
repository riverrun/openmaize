defmodule Sanction.AuthenticateTest do
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
    token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJpZCI6IlJheW1vbmQgTHV4dXJ5IFlhY2h0In0.L4J3kHwl3K5LqAOVqTGskzsUuDsv-rf0xhkSS9g6gYL_SlD7BOYLghItE1U-jHAHpuNnmhlvmmyW4hAIKMgGkw"
    conn = conn(:get, "/") |> put_req_cookie("access_token", token) |> call([])
    assert conn.status == 200
    assert conn.assigns == %{authenticated_user: %{id: "Raymond Luxury Yacht"}}
  end

  test "error for invalid token" do
    token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJpZCI6IlJheW1vbmQgTHV4dXJ5IFlhY2h0In0.eIBGE2fWD8nU0WHuuh8skEG1R789FObmDRiHybI18oMfH1UPuzAuzwUE6P4eQakNIZPMFensifQLoD3r7kzR-Q"
    assert_raise InvalidTokenError, fn ->
      conn(:get, "/") |> put_req_cookie("access_token", token) |> call([])
    end
  end

  test "error for missing token" do
    assert_raise InvalidTokenError, fn ->
      conn(:get, "/") |> call([])
    end
  end

end
