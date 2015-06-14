defmodule Openmaize.ApiTest do
  use ExUnit.Case
  use Plug.Test

  @admin_token "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9." <>
  "eyJyb2xlIjoiYWRtaW4iLCJuYW1lIjoiQmlnIEJvc3MiLCJpZCI6Mn0." <>
  "eCWmeWSs5vM9mxScrFoknZgcbW0Q8OMLzyHMyj7KKZI1mDD1N6cCY8laPYS0fK2v17DIvTQ-mZgDrezk9CGICw"

  @user_token "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9." <>
  "eyJyb2xlIjoidXNlciIsIm5hbWUiOiJSYXltb25kIEx1eHVyeSBZYWNodCIsImlkIjoxfQ." <>
  "oeUo6ZWA2VlaqQQzMa1mqIeEJvaIZfsUrtulgjgzvjqTc4MVjKps3Tqwxdxi5GRYoUOMRGiQgnedOfc8islEnA"

  def call(conn) do
    conn |> Openmaize.call([redirects: false])
  end

  test "unauthorized login" do
    conn = conn(:get, "/api") |> call
    assert conn.status == 401
  end

  test "correct token with role admin" do
    conn = conn(:get, "/api") |> put_req_header("access-token", "#{@admin_token}") |> call |> send_resp(200, "")
    assert conn.status == 200
    assert conn.assigns == %{current_user: %{id: 2, name: "Big Boss", role: "admin"}}
  end

  test "redirect for insufficient permissions" do
    conn = conn(:get, "/api") |> put_req_header("access-token", "#{@user_token}") |> call
    assert conn.status == 403
  end

end
