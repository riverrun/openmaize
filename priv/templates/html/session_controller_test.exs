defmodule <%= base %>.SessionControllerTest do
  use <%= base %>.ConnCase

  import <%= base %>.OpenmaizeEcto<%= if confirm do %>
  alias <%= base %>.{Repo, User}

  @valid_link "email=gladys%40mail.com&key=pu9-VNdgE8V9qZo19rlcg3KUNjpxuixg"
  @invalid_link "email=gladys%40mail.com&key=pu9-VNdgE8V9QzO19RLCG3KUNjpxuixg"<% end %>

  @valid_attrs %{email: "tony@mail.com", password: "mangoes&g0oseberries"}
  @invalid_attrs %{email: "tony@mail.com", password: "maaaangoes&g00zeberries"}

  setup %{conn: conn} do
    conn = conn |> bypass_through(<%= base %>.Router, :browser) |> get("/")
    user_conn = conn |> put_session(:user_id, 3) |> send_resp(:ok, "/")

    {:ok, %{conn: conn, user_conn: user_conn}}
  end

  test "login succeeds", %{conn: conn} do<%= if confirm do %>
    Repo.get_by(User, %{email: "tony@mail.com"}) |> user_confirmed<% end %>
    conn = post conn, session_path(conn, :create), user: @valid_attrs
    assert redirected_to(conn) == user_path(conn, :index)
  end

  test "login fails", %{conn: conn} do<%= if confirm do %>
    Repo.get_by(User, %{email: "reg@mail.com"}) |> user_confirmed<% end %>
    conn = post conn, session_path(conn, :create), user: @invalid_attrs
    assert redirected_to(conn) == session_path(conn, :new)
  end

  test "logout succeeds", %{user_conn: user_conn} do
    conn = delete user_conn, session_path(user_conn, :delete)
    assert redirected_to(user_conn) == page_path(user_conn, :index)
  end<%= if confirm do %>

  test "confirmation succeeds for correct key", %{conn: conn} do
    conn = get(conn, "/confirm_email?" <> @valid_link)
    assert conn.private.phoenix_flash["info"] =~ "successfully confirmed"
    assert redirected_to(conn) == session_path(conn, :new)
  end

  test "confirmation fails for incorrect key", %{conn: conn} do
    conn = get(conn, "/confirm_email?" <> @invalid_link)
    assert conn.private.phoenix_flash["error"] =~ "failed"
    assert redirected_to(conn) == session_path(conn, :new)
  end<% end %>

end
