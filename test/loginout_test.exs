defmodule Openmaize.LoginoutTest do
  use ExUnit.Case
  use Plug.Test

  alias Openmaize.LoginoutCheck

  test "call Openmaize with admin login page" do
    conn = conn(:get, "/admin/login") |> LoginoutCheck.call([]) |> send_resp(200, "")
    assert conn.status == 200
    assert conn.private.openmaize_skip == true
  end

  test "call Openmaize with api login page" do
    conn = conn(:get, "/api/login") |> LoginoutCheck.call([]) |> send_resp(200, "")
    assert conn.status == 200
    assert conn.private.openmaize_skip == true
  end

  test "redirect on logout" do
    conn = conn(:get, "/admin/logout") |> LoginoutCheck.call([])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
           {"location", "/"}
    assert conn.status == 302
    assert conn.private.openmaize_skip == true
  end

end
