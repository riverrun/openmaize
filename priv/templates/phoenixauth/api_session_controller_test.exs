defmodule <%= base %>.SessionControllerTest do
  use <%= base %>.ConnCase

  import <%= base %>.TestHelpers

  @valid_attrs %{username: "robin", password: "mangoes&g0oseberries"}
  @invalid_attrs %{username: "robin", password: "maaaangoes&g00zeberries"}

  setup %{conn: conn} do
    user = add_user("robin")
    conn = conn |> add_token_conn(user)
    {:ok, %{conn: conn, user: user}}
  end

  test "login succeeds", %{conn: conn} do
    conn = post conn, session_path(conn, :create), session: @valid_attrs
    assert json_response(conn, 200)["info"]["detail"]
  end

  test "login fails", %{conn: conn} do
    conn = post conn, session_path(conn, :create), session: @invalid_attrs
    assert json_response(conn, 401)["errors"]["detail"] =~ "need to login"
  end

end
