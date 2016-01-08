defmodule Openmaize.Authorize.IdCheckTest do
  use ExUnit.Case
  use Plug.Test

  use Openmaize.AccessControl

  @user %{id: 1, name: "Raymond Luxury Yacht", role: "user"}

  def call(conn, id, opts) do
    %{conn | params: %{"id" => id}}
    |> assign(:current_user, @user)
    |> authorize_id(opts)
  end

  test "user with correct id can access page" do
    path = "/users/1/edit"
    conn = conn(:get, path) |> call("1", [redirects: true]) |> send_resp(200, "")
    assert conn.status == 200
  end

  test "user with wrong id cannot access resource and is redirected" do
    path = "/users/10/edit"
    conn = conn(:get, path) |> call("10", [redirects: true])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
    {"location", "/users"}
    assert conn.status == 302
  end

  test "user with wrong id and no options is redirected" do
    path = "/users/10/edit"
    conn = conn(:get, path) |> call("10", [])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
    {"location", "/users"}
    assert conn.status == 302
  end

  test "user with wrong id cannot access resource" do
    path = "/users/10/edit"
    conn = conn(:get, path) |> call("10", [redirects: false])
    assert conn.status == 403
  end

end
