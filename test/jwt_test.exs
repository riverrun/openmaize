defmodule Openmaize.JWTTest do
  use ExUnit.Case
  use Plug.Test

  import Openmaize.{JWT, JWT.Verify}

  test "token not stored in cookie" do
    user = %{id: 1, username: "Raymond Luxury Yacht", role: "user"}
    conn = conn(:get, "/") |> add_token(user, {nil, :username})
    assert String.starts_with?(conn.resp_body, "{\"access_token\":")
    assert conn.status == 200
  end

  test "token with custom unique_id" do
    user = %{id: 1, email: "ray@mail.com", role: "user"}
    conn = conn(:get, "/") |> add_token(user, {:cookie, :email})
    token = conn.resp_cookies["access_token"].value
    {:ok, data} = verify_token(token)
    assert data.email
  end

end
