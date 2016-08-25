defmodule <%= base %>.PasswordResetControllerTest do
  use <%= base %>.ConnCase

  import <%= base %>.OpenmaizeEcto
  alias <%= base %>.{Repo, User}

  @valid_attrs %{email: "gladys@mail.com", password: "^hEsdg*F899",
    key: "pu9-VNdgE8V9qZo19rlcg3KUNjpxuixg"}
  @invalid_attrs %{email: "gladys@mail.com",  password: "^hEsdg*F899",
    key: "pu9-VNDGe8v9QzO19RLCg3KUNjpxuixg"}
  @invalid_pass %{email: "gladys@mail.com", password: "qwerty",
    key: "pu9-VNdgE8V9qZo19rlcg3KUNjpxuixg"}


  test "reset password succeeds for correct key", %{conn: conn} do
    conn = post(conn, "/password_resets/update", user: @valid_attrs)
    assert conn.private.phoenix_flash["info"] =~ "successfully confirmed"
    assert redirected_to(conn) == "/login"
  end

  test "reset password fails for incorrect key", %{conn: conn} do
    conn = post(conn, "/password_resets/update", user: @invalid_attrs)
    assert conn.private.phoenix_flash["error"] =~ "failed"
  end

  test "reset password fails for invalid password", %{conn: conn} do
    conn = post(conn, "/password_resets/update", user: @invalid_pass)
    assert conn.private.phoenix_flash["error"] =~ "password should be"
  end

end
