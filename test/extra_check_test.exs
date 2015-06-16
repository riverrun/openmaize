defmodule Openmaize.ExtraCheckTest do
  use ExUnit.Case
  use Plug.Test

  @user_token "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9." <>
  "eyJyb2xlIjoidXNlciIsIm5hbWUiOiJSYXltb25kIEx1eHVyeSBZYWNodCIsImlkIjoxfQ." <>
  "oeUo6ZWA2VlaqQQzMa1mqIeEJvaIZfsUrtulgjgzvjqTc4MVjKps3Tqwxdxi5GRYoUOMRGiQgnedOfc8islEnA"

  def call(conn) do
    conn |> Openmaize.call([check: &id_check/2])
  end

  def id_check(conn, %{role: role} = data) do
    case verify_id(conn, data) do
      true -> {:ok, data}
      false -> {:error, role, "You cannot view this page."}
    end
  end

  def verify_id(conn, %{id: id}) do
    path = full_path(conn)
    if Regex.match?(~r{/users/[0-9]+/}, path) do
      Kernel.match?({0, _}, :binary.match(path, "/users/#{id}/"))
    else
      true
    end
  end

  test "need id to edit page with id" do
    conn = conn(:get, "/users/1/edit") |> put_req_cookie("access_token", @user_token) |> call |> send_resp(200, "")
    assert conn.status == 200
    assert conn.assigns == %{current_user: %{id: 1, name: "Raymond Luxury Yacht", role: "user"}}
  end

  test "user with wrong id, but start of id is the same" do
    conn = conn(:get, "/users/10/edit") |> put_req_cookie("access_token", @user_token) |> call
    assert List.keyfind(conn.resp_headers, "location", 0) ==
           {"location", "http://www.example.com/users"}
    assert conn.status == 302
  end

  test "user with wrong id -- cannot edit" do
    conn = conn(:get, "/users/3/edit") |> put_req_cookie("access_token", @user_token) |> call
    assert List.keyfind(conn.resp_headers, "location", 0) ==
           {"location", "http://www.example.com/users"}
    assert conn.status == 302
  end

end
