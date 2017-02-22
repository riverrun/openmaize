defmodule <%= base %>.PasswordResetControllerTest do
  use <%= base %>.ConnCase

  import <%= base %>.TestHelpers

  @valid_attrs %{email: "gladys@mail.com", password: "^hEsdg*F899",
    key: "pu9-VNdgE8V9qZo19rlcg3KUNjpxuixg"}
  @invalid_email %{email: "fred@mail.com", password: "^hEsdg*F899",
    key: "pu9-VNdgE8V9qZo19rlcg3KUNjpxuixg"}
  @invalid_attrs %{email: "gladys@mail.com",  password: "^hEsdg*F899",
    key: "pu9-VNDGe8v9QzO19RLCg3KUNjpxuixg"}
  @invalid_pass %{email: "gladys@mail.com", password: "qwerty",
    key: "pu9-VNdgE8V9qZo19rlcg3KUNjpxuixg"}

  setup %{conn: conn} do
    add_reset("gladys")
    {:ok, %{conn: conn}}
  end

  test "reset password succeeds for correct key", %{conn: conn} do
    conn = put(conn, password_reset_path(conn, :update), password_reset: @valid_attrs)
    assert json_response(conn, 200)["info"]["detail"]
  end

  test "reset password fails for invalid email", %{conn: conn} do
    conn = post(conn, password_reset_path(conn, :create), password_reset: @invalid_email)
    IO.inspect conn
    assert json_response(conn, 200)["info"]["detail"]
  end

  test "reset password fails for incorrect key", %{conn: conn} do
    conn = put(conn, password_reset_path(conn, :update), password_reset: @invalid_attrs)
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "reset password fails for invalid password", %{conn: conn} do
    conn = put(conn, password_reset_path(conn, :update), password_reset: @invalid_pass)
    assert json_response(conn, 422)["errors"] != %{}
  end
end
