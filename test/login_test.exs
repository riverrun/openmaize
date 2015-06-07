defmodule Openmaize.LoginTest do
  use ExUnit.Case
  use Plug.Test

  test "call Openmaize with login page" do
    conn = conn(:get, "/admin/login") |> Openmaize.call([]) |> send_resp(200, "")
    assert conn.status == 200
  end

end
