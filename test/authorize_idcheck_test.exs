defmodule Openmaize.Authorize.IdCheckTest do
  use ExUnit.Case
  use Plug.Test

  import Openmaize.AccessControl

  @admin %{id: 2, name: "Big Boss", role: "admin"}
  @user %{id: 1, name: "Raymond Luxury Yacht", role: "user"}

  def call(conn, id, user) do
    %{conn | params: %{"id" => id}} |> assign(:current_user, user)
  end

  def custom_auth(%Plug.Conn{assigns: %{current_user: %{role: "admin"}}} = conn, _opts) do
    conn
  end
  def custom_auth(conn, opts), do: authorize_id(conn, opts)

  test "user with correct id can access page" do
    path = "/users/1/edit"
    conn = conn(:get, path) |> call("1", @user) |> authorize_id([]) |> send_resp(200, "")
    assert conn.status == 200
  end

  test "user with wrong id cannot access resource and is redirected" do
    path = "/users/10/edit"
    conn = conn(:get, path) |> call("10", @user) |> authorize_id([])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
      {"location", "/users"}
    assert conn.status == 302
  end

  test "user with wrong id and no options is redirected" do
    path = "/users/10/edit"
    conn = conn(:get, path) |> call("10", @user) |> authorize_id([])
    assert List.keyfind(conn.resp_headers, "location", 0) ==
      {"location", "/users"}
    assert conn.status == 302
  end

  test "user with wrong id cannot access resource" do
    path = "/users/10/edit"
    conn = conn(:get, path) |> call("10", @user) |> authorize_id([redirects: false])
    assert conn.status == 403
  end

  test "customized authorize_id" do
    path = "/users/1/edit"
    conn = conn(:get, path) |> call("2", @admin) |> custom_auth([]) |> send_resp(200, "")
    assert conn.status == 200
  end

  test "customized authorize_id with correct user id" do
    path = "/users/1/edit"
    conn = conn(:get, path) |> call("1", @user) |> custom_auth([]) |> send_resp(200, "")
    assert conn.status == 200
  end

end
