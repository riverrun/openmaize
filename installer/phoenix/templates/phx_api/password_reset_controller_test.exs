defmodule <%= base %>.PasswordResetControllerTest do
  use <%= base %>.ConnCase

  import <%= base %>.TestHelpers

  @valid_attrs %{email: "gladys@mail.com", password: "^hEsdg*F899",
    key: "pu9-VNdgE8V9qZo19rlcg3KUNjpxuixg"}
  @invalid_attrs %{email: "gladys@mail.com",  password: "^hEsdg*F899",
    key: "pu9-VNDGe8v9QzO19RLCg3KUNjpxuixg"}
  @invalid_pass %{email: "gladys@mail.com", password: "qwerty",
    key: "pu9-VNdgE8V9qZo19rlcg3KUNjpxuixg"}

  setup %{conn: conn} do
    user = add_reset("gladys")
    {:ok, %{conn: conn, user: user}}
  end

  test "reset password succeeds for correct key", %{conn: conn, user: user} do
    conn = put(conn, password_reset_path(conn, :update, user), password_reset: @valid_attrs)
    assert json_response(conn, 200)["info"]["detail"]
  end

  test "reset password fails for incorrect key", %{conn: conn, user: user} do
    conn = put(conn, password_reset_path(conn, :update, user), password_reset: @invalid_attrs)
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "reset password fails for invalid password", %{conn: conn, user: user} do
    conn = put(conn, password_reset_path(conn, :update, user), password_reset: @invalid_pass)
    assert json_response(conn, 422)["errors"] != %{}
  end
end
