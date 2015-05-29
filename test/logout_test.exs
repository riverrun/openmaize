defmodule Openmaize.LogoutTest do
  use ExUnit.Case
  use Plug.Test

  alias Openmaize.Authenticate

  test "redirect on logout" do
    conn = conn(:get, "/users/logout") |> Authenticate.call([])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
           {"location", "http://www.example.com/"}
    assert conn.status == 301
  end

end
