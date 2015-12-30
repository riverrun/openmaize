defmodule Openmaize.ReportTest do
  use ExUnit.Case
  use Plug.Test

  alias Openmaize.Report

  test "handle_error for no user with redirects" do
    conn = conn(:get, "/admin")
    |> Report.handle_error("You have beautiful thighs!", true)
    assert List.keyfind(conn.resp_headers, "location", 0) ==
           {"location", "/admin/login"}
    assert conn.status == 302
  end

  test "handle_error for unauthorized access with redirects" do
    conn = conn(:get, "/admin")
    |> Report.handle_error("user", "What are you doing here?", true)
    assert List.keyfind(conn.resp_headers, "location", 0) ==
           {"location", "/users"}
    assert conn.status == 302
  end

  test "handle_info/2" do
    conn = conn(:get, "/admin")
    |> Report.handle_info("I hear the mangoes are doing very well, and so are the gooseberries.")
    assert List.keyfind(conn.resp_headers, "location", 0) ==
           {"location", "/"}
    assert conn.status == 302
  end

  test "handle_info/3" do
    conn = conn(:get, "/admin")
    |> Report.handle_info("user", "I'd love to give you more information, but I'm too expensive.")
    assert List.keyfind(conn.resp_headers, "location", 0) ==
           {"location", "/users"}
    assert conn.status == 302
  end

  test "handle_error for no user with no redirects" do
    conn = conn(:get, "/admin")
    |> Report.handle_error("Get out of here!", false)
    assert conn.status == 401
    assert conn.halted == true
  end

  test "handle_error for unauthorized access with no redirects" do
    conn = conn(:get, "/admin")
    |> Report.handle_error("user", "Get out of here!", false)
    assert conn.status == 403
    assert conn.halted == true
  end

end
