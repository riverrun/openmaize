defmodule Openmaize.LoginTest do
  use ExUnit.Case
  use Plug.Test

  test "call Openmaize with path ending in login" do
    conn = conn(:get, "/users/login") |> Openmaize.call([]) |> send_resp(200, "")
    assert conn.status == 200
    conn = conn(:get, "/admin/login") |> Openmaize.call([]) |> send_resp(200, "")
    assert conn.status == 200
  end

end
