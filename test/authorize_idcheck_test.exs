defmodule Openmaize.Authorize.IdCheckTest do
  use ExUnit.Case
  use Plug.Test

  import Openmaize.AccessControl

  @admin %{id: 2, username: "Big Boss", role: "admin"}
  @user %{id: 1, username: "Raymond Luxury Yacht", role: "user"}

  def call(conn, id, user) do
    %{conn | params: %{"id" => id}}
    |> assign(:current_user, user)
    |> authorize_id([])
  end

  test "user with correct id can access page" do
    path = "/users/1/edit"
    conn = conn(:get, path) |> call("1", @user) |> send_resp(200, "")
    refute conn.private[:openmaize_error]
    assert conn.status == 200
  end

  test "user with wrong id cannot access resource" do
    path = "/users/10/edit"
    conn = conn(:get, path) |> call("10", @user)
    assert conn.private.openmaize_error =~ "You do not have permission to view"
  end

end
