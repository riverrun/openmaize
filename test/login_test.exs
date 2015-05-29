defmodule Openmaize.LoginTest do
  use ExUnit.Case
  use Plug.Test

  alias Openmaize.Authenticate

  test "call to Authenticate with /users/login go straight to login page" do
    conn = conn(:get, "/users/login") |> Authenticate.call([]) |> send_resp(200, "")
    assert conn.status == 200
  end

end
