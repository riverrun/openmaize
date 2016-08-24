defmodule <%= base %>.SessionControllerTest do
  use <%= base %>.ConnCase

  import <%= base %>.OpenmaizeEcto<%= if confirm do %>
  alias <%= base %>.{Repo, User}

  @valid_confirm "email=gladys%40mail.com&key=pu9-VNdgE8V9qZo19rlcg3KUNjpxuixg"
  @invalid_confirm "email=gladys%40mail.com&key=pu9-VNdgE8V9QzO19RLCG3KUNjpxuixg"<% end %>

  @valid_attrs %{email: "tony@mail.com", password: "mangoes&g0oseberries"}
  @invalid_attrs %{email: "tony@mail.com", password: "maaaangoes&g00zeberries"}

  setup %{conn: conn} do
    conn = conn |> bypass_through(<%= base %>.Router, :browser) |> get("/")
    user_conn = conn |> put_session(:user_id, 3) |> send_resp(:ok, "/")

    {:ok, %{conn: conn, user_conn: user_conn}}
  end

  test "login succeeds", %{conn: conn} do<%= if confirm do %>
    Repo.get_by(User, %{email: "tony@mail.com"}) |> user_confirmed<% end %>
    conn = post conn, "/login", user: @valid_attrs
    assert redirected_to(conn) == "/users"
  end

  test "login fails", %{conn: conn} do<%= if confirm do %>
    Repo.get_by(User, %{email: "reg@mail.com"}) |> user_confirmed<% end %>
    conn = post conn, "/login", user: @invalid_attrs
    assert redirected_to(conn) == "/login"
  end

  test "logout succeeds", %{user_conn: user_conn} do
    conn = delete user_conn, "/logout"
    assert redirected_to(conn) == "/"
  end

  test "confirmation succeeds for correct key" do
    conn = build_conn() |> get("/confirm_email?" <> @valid_confirm)
    assert conn.private.phoenix_flash["info"] =~ "successfully confirmed"
    assert redirected_to(conn) == "/login"
  end

  test "confirmation fails for incorrect key" do
    conn = build_conn() |> get("/confirm_email?" <> @invalid_confirm)
    assert conn.private.phoenix_flash["error"] =~ "failed"
    assert redirected_to(conn) == "/login"
  end

end
