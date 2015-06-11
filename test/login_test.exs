defmodule Openmaize.LoginTest do
  use ExUnit.Case
  use Plug.Test

  test "call Openmaize with admin login page" do
    conn = conn(:get, "/admin/login") |> Openmaize.call([]) |> send_resp(200, "")
    assert conn.status == 200
  end

  test "call Openmaize with api login page" do
    conn = conn(:get, "/api/login") |> Openmaize.call([]) |> send_resp(200, "")
    assert conn.status == 200
  end

end
