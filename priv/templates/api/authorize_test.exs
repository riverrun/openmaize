defmodule <%= base %>.AuthorizeTest do
  use <%= base %>.ConnCase

  import <%= base %>.OpenmaizeEcto
  import OpenmaizeJWT.Create
  alias <%= base %>.{Repo, User}

  @valid_attrs %{email: "tony@mail.com", password: "mangoes&g0oseberries"}
  @invalid_attrs %{email: "tony@mail.com", password: "maaaangoes&g00zeberries"}

  @secret String.duplicate("12345678", 8)

  {:ok, user_token} = %{id: 3, email: "tony@mail.com", role: "user"}
                      |> generate_token({0, 1440}, @secret)
  @user_token user_token

  setup %{conn: conn} do
    conn = conn
            |> put_req_header("accept", "application/json")
            |> put_req_header("authorization", "Bearer #{@user_token}")
    {:ok, conn: conn}
  end

  test "login succeeds" do
    # Uncomment the Repo.get_by line if you are using email confirmation
    #Repo.get_by(User, %{email: "tony@mail.com"}) |> user_confirmed
    conn = post build_conn(), "/api/login", user: @valid_attrs
    assert response(conn, 200)
  end

  test "login fails" do
    # Uncomment the Repo.get_by line if you are using email confirmation
    #Repo.get_by(User, %{email: "reg@mail.com"}) |> user_confirmed
    conn = post build_conn(), "/api/login", user: @invalid_attrs
    assert response(conn, 401)
  end

  test "logout succeeds" do
  {:ok, user_token} = %{id: 3, email: "tony@mail.com", role: "user"}
                      |> generate_token({0, 1440}, @secret)
    conn = build_conn()
    |> put_req_cookie("access_token", user_token)
    |> get("/api/logout")
    assert response(conn, 200)
  end

end
