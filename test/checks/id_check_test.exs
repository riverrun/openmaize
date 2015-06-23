defmodule Openmaize.IdCheckTest do
  use ExUnit.Case
  use Plug.Test

  import Openmaize.IdCheck
  alias Openmaize.Authorize

  @user %{id: 1, name: "Raymond Luxury Yacht", role: "user"}

  def noedit(conn) do
    conn |> Authorize.call([check: &id_noedit/4])
  end

  def noshow(conn) do
    conn |> Authorize.call([check: &id_noshow/4])
  end

  test "user with correct id can edit" do
    conn = conn(:get, "/users/1/edit")
            |> assign(:current_user, @user)
            |> noedit
            |> send_resp(200, "")
    assert conn.status == 200
  end

  test "user with correct id can show" do
    conn = conn(:get, "/users/1")
            |> assign(:current_user, @user)
            |> noedit
            |> send_resp(200, "")
    assert conn.status == 200
  end

  test "user with wrong id, but start of id is the same" do
    conn = conn(:get, "/users/10/edit")
            |> assign(:current_user, @user)
            |> noedit
    assert List.keyfind(conn.resp_headers, "location", 0) ==
           {"location", "http://www.example.com/users"}
    assert conn.status == 302
  end

  test "user with wrong id -- cannot edit" do
    conn = conn(:get, "/users/3/edit")
            |> assign(:current_user, @user)
            |> noedit
    assert List.keyfind(conn.resp_headers, "location", 0) ==
           {"location", "http://www.example.com/users"}
    assert conn.status == 302
  end

  test "user with wrong id -- cannot show" do
    conn = conn(:get, "/users/3")
            |> assign(:current_user, @user)
            |> noshow
    assert List.keyfind(conn.resp_headers, "location", 0) ==
           {"location", "http://www.example.com/users"}
    assert conn.status == 302
  end

end
