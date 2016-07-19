defmodule <%= base %>.AuthorizeTest do
  use <%= base %>.ConnCase

  import <%= base %>.OpenmaizeEcto
  alias <%= base %>.{Repo, User}

  @valid_attrs %{email: "tony@mail.com", password: "mangoes&g0oseberries"}
  @invalid_attrs %{email: "tony@mail.com", password: "maaaangoes&g00zeberries"}

  # In this example setup, `conn` is the connection for an unauthenticated
  # user, and `user_conn` is for an authenticated user (with an id of 3)
  setup %{conn: conn} do
    conn = conn |> bypass_through(<%= base %>.Router, :browser) |> get("/")
    user_conn = conn |> put_session(:user_id, 3) |> send_resp(:ok, "/")

    {:ok, %{conn: conn, user_conn: user_conn}}
  end

  # The first three tests can be used to test routes protected by
  # the role_check plug or the custom action (authorize_action) function
  test "correct user role is successfully authorized", %{user_conn: user_conn} do
    conn = get user_conn, "/users"
    assert html_response(conn, 200)
  end

  test "authorization for incorrect role fails", %{user_conn: user_conn} do
    conn = get user_conn, "/admin"
    assert redirected_to(conn) == "/users"
  end

  test "authorization for nil user fails", %{conn: conn} do
    conn = conn |> get("/users")
    assert redirected_to(conn) == "/login"
  end

  # Test routes protected by the id_check plug
  test "id check succeeds", %{user_conn: user_conn} do
    conn = get user_conn, "/users/3"
    assert html_response(conn, 200)
  end

  test "id check fails for incorrect id", %{user_conn: user_conn} do
    conn = get user_conn, "/users/30"
    assert redirected_to(conn) == "/users"
  end

  test "id check fails for nil user", %{conn: conn} do
    conn = conn |> get("/users/3")
    assert redirected_to(conn) == "/login"
  end

  test "login succeeds", %{conn: conn} do
    # Remove the Repo.get_by line if you are not using email confirmation
    Repo.get_by(User, %{email: "tony@mail.com"}) |> user_confirmed
    conn = post conn, "/login", user: @valid_attrs
    assert redirected_to(conn) == "/users"
  end

  test "login fails", %{conn: conn} do
    # Remove the Repo.get_by line if you are not using email confirmation
    Repo.get_by(User, %{email: "reg@mail.com"}) |> user_confirmed
    conn = post conn, "/login", user: @invalid_attrs
    assert redirected_to(conn) == "/login"
  end

  test "logout succeeds", %{user_conn: user_conn} do
    conn = delete user_conn, "/logout"
    assert redirected_to(conn) == "/"
  end

end
