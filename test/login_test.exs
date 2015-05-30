defmodule Openmaize.LoginTest do
  use ExUnit.Case
  use Plug.Test

  alias Openmaize.Authenticate

  test "call Authenticate with path ending in login" do
    conn = conn(:get, "/users/login") |> Authenticate.call([]) |> send_resp(200, "")
    assert conn.status == 200
    conn = conn(:get, "/admin/login") |> Authenticate.call([]) |> send_resp(200, "")
    assert conn.status == 200
  end

end
