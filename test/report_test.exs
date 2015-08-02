defmodule Openmaize.ReportTest do
  use ExUnit.Case
  use Plug.Test

  alias Openmaize.Report

  test "handle_error/2" do
    conn = conn(:get, "/admin")
    |> Report.handle_error("You have beautiful thighs!")
    assert List.keyfind(conn.resp_headers, "location", 0) ==
           {"location", "http://www.example.com/admin/login"}
    assert conn.status == 302
  end

  test "handle_error/3" do
    conn = conn(:get, "/admin")
    |> Report.handle_error("user", "What are you doing here?")
    assert List.keyfind(conn.resp_headers, "location", 0) ==
           {"location", "http://www.example.com/users"}
    assert conn.status == 302
  end

  test "handle_info/2" do
    conn = conn(:get, "/admin")
    |> Report.handle_info("I hear the mangoes are doing very well, and so are the gooseberries.")
    assert List.keyfind(conn.resp_headers, "location", 0) ==
           {"location", "http://www.example.com/"}
    assert conn.status == 302
  end

  test "handle_info/3" do
    conn = conn(:get, "/admin")
    |> Report.handle_info("user", "I'd love to give you more information, but I'm too expensive.")
    assert List.keyfind(conn.resp_headers, "location", 0) ==
           {"location", "http://www.example.com/users"}
    assert conn.status == 302
  end

  test "send_error/3 no redirects" do
    conn = conn(:get, "/admin")
    |> Report.send_error(401, "Get out of here!")
    assert conn.status == 401
    assert conn.halted == true
    assert conn.private.openmaize_skip == true
  end

end
