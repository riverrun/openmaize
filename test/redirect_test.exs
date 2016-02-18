defmodule Openmaize.RedirectTest do
  use ExUnit.Case
  use Plug.Test

  alias Openmaize.Redirect

  @user %{id: 1, name: "Raymond Luxury Yacht", role: "user"}
  @user_redirect "/users"
  @janitor %{id: 5, name: "Gladys Stoate", role: "janitor"}
  @janitor_redirect "/users/:id"

  test "user gets redirected to `/users` page" do
    conn = conn(:get, "/")
    |> assign(:current_user, @user)
    |> Redirect.redirect_to(@user_redirect, "You have been logged in")
    assert List.keyfind(conn.resp_headers, "location", 0) ==
      {"location", "/users"}
    assert conn.status == 302
    assert conn.private.openmaize_info == "You have been logged in"
  end

  test "janitor gets redirected to correct id page" do
    conn = conn(:get, "/")
    |> assign(:current_user, @janitor)
    |> Redirect.redirect_to(@janitor_redirect, "You have been logged in")
    assert List.keyfind(conn.resp_headers, "location", 0) ==
      {"location", "/users/5"}
    assert conn.status == 302
    assert conn.private.openmaize_info == "You have been logged in"
  end

end
