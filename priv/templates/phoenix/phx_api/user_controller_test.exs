defmodule <%= base %>.UserControllerTest do
  use <%= base %>.ConnCase

  import <%= base %>.TestHelpers
  alias <%= base %>.{Repo, User}

  @valid_attrs %{username: "bill", email: "bill@mail.com", password: "^hEsdg*F899"}
  @invalid_attrs %{email: "", password: ""}

  setup %{conn: conn} = config do
    if username = config[:login] do<%= if confirm do %>
      user = add_user_confirmed(username)
      other = add_user_confirmed("tony")<% else %>
      user = add_user(username)
      other = add_user("tony")<% end %>

      conn = conn |> add_token_conn(user)
      {:ok, %{conn: conn, user: user, other: other}}
    else
      {:ok, %{conn: conn}}
    end
  end

  @tag login: "reg"
  test "GET /users for authorized user", %{conn: conn} do
    conn = get conn, user_path(conn, :index)
    assert json_response(conn, 200)
  end

  test "GET /users error for unauthorized user", %{conn: conn}  do
    conn = get conn, user_path(conn, :index)
    assert json_response(conn, 401)
  end

  test "creates resource when data is valid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(User, %{email: "bill@mail.com"})
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  @tag login: "reg"
  test "GET /users/:id", %{conn: conn, user: user} do
    conn = get conn, user_path(conn, :show, user)
    assert json_response(conn, 200)["data"] == %{"id" => user.id, "username" => "reg"}
  end

  @tag login: "reg"
  test "PUT /users/:id with valid data", %{conn: conn, user: user} do
    conn = put conn, user_path(conn, :update, user), user: @valid_attrs
    assert json_response(conn, 200)["data"]["id"] == user.id
    new_user = Repo.get(User, user.id)
    assert new_user.username == "bill"
    assert new_user.email == "bill@mail.com"
  end

  @tag login: "reg"
  test "PUT /users/:id with invalid data", %{conn: conn, user: user} do
    conn = put conn, user_path(conn, :update, user), user: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  @tag login: "reg"
  test "deletes current user", %{conn: conn, user: user} do
    conn = delete conn, user_path(conn, :delete, user)
    assert response(conn, 204)
    refute Repo.get(User, user.id)
  end

  @tag login: "reg"
  test "cannot delete other user", %{conn: conn, other: other} do
    conn = delete conn, user_path(conn, :delete, other)
    assert json_response(conn, 403)["errors"]["detail"] =~ "not authorized"
    assert Repo.get(User, other.id)
  end
end
