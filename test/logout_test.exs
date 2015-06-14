defmodule Openmaize.LogoutTest do
  use ExUnit.Case
  use Plug.Test

  test "redirect on logout" do
    conn = conn(:get, "/admin/logout") |> Openmaize.call([])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
           {"location", "http://www.example.com/"}
    assert conn.status == 302
  end

end
