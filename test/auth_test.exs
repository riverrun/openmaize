defmodule Openmaize.AuthTest do
  use ExUnit.Case
  use Plug.Test

  @user_token "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9." <>
  "eyJyb2xlIjoidXNlciIsIm5hbWUiOiJSYXltb25kIEx1eHVyeSBZYWNodCIsImlkIjoxfQ." <>
  "oeUo6ZWA2VlaqQQzMa1mqIeEJvaIZfsUrtulgjgzvjqTc4MVjKps3Tqwxdxi5GRYoUOMRGiQgnedOfc8islEnA"

  @invalid "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9." <>
  "eyJpZCI6IlJheW1vbmQgTHV4dXJ5IFlhY2h0In0." <>
  "eIBGE2fWD8nU0WHuuh8skEG1R789FObmDRiHybI18oMfH1UPuzAuzwUE6P4eQakNIZPMFensifQLoD3r7kzR-Q"

  def call(conn) do
    {time, conn} = :timer.tc(Openmaize, :call, [conn, []])
    #conn |> Openmaize.call([]) |> send_resp(200, "")
    IO.inspect time
    send_resp(conn, 200, "")
  end

  test "correct token stored in cookie" do
    Application.put_env(:openmaize, :storage_method, :cookie)
    conn = conn(:get, "/") |> put_req_cookie("access_token", @user_token) |> call
    assert conn.status == 200
    assert conn.assigns == %{current_user: %{id: 1, name: "Raymond Luxury Yacht", role: "user"}}
    Application.delete_env(:openmaize, :storage_method)
  end

  test "missing token for unprotected page" do
    conn = conn(:get, "/") |> call
    assert conn.status == 200
    assert conn.assigns == %{current_user: nil}
  end
end
