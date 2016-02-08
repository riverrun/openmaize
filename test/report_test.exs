defmodule Openmaize.ReportTest do
  use ExUnit.Case
  use Plug.Test

  alias Openmaize.Report

  test "put_message for no user with redirects" do
    conn = conn(:get, "/admin")
    |> Report.put_message(%{"error" => "You have beautiful thighs!"}, true)
    assert List.keyfind(conn.resp_headers, "location", 0) ==
           {"location", "/login"}
    assert conn.status == 302
  end

  test "put_message for unauthorized access with redirects" do
    conn = conn(:get, "/admin")
    |> Report.put_message("user", %{"error" => "What are you doing here?"}, true)
    assert List.keyfind(conn.resp_headers, "location", 0) ==
           {"location", "/users"}
    assert conn.status == 302
  end

  test "put_message for no user with no redirects" do
    conn = conn(:get, "/admin")
    |> Report.put_message(%{"error" => "Get out of here!"}, false)
    assert conn.status == 401
    assert conn.halted == true
  end

  test "put_message for unauthorized access with no redirects" do
    conn = conn(:get, "/admin")
    |> Report.put_message("user", %{"error" => "Get out of here!"}, false)
    assert conn.status == 403
    assert conn.halted == true
  end

end
