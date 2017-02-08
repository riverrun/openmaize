defmodule <%= base %>.SessionControllerTest do
  use <%= base %>.ConnCase

  import <%= base %>.TestHelpers

  @valid_attrs %{email: "robin@mail.com", password: "mangoes&g0oseberries"}
  @invalid_attrs %{email: "robin@mail.com", password: "maaaangoes&g00zeberries"}

  setup %{conn: conn} do<%= if confirm do %>
    add_user("arthur")
    user = add_user_confirmed("robin")<% else %>
    user = add_user("robin")<% end %>

    conn = conn |> add_token_conn(user)
    {:ok, %{conn: conn}}
  end

  test "login succeeds", %{conn: conn} do
    conn = post conn, session_path(conn, :create), session: @valid_attrs
    assert json_response(conn, 200)["info"]["detail"]
  end

  test "login fails", %{conn: conn} do
    conn = post conn, session_path(conn, :create), session: @invalid_attrs
    assert json_response(conn, 401)["errors"]["detail"] =~ "need to login"
  end<%= if confirm do %>

  test "confirmation succeeds for correct key", %{conn: conn} do
    email = "arthur@mail.com"
    key = "pu9-VNdgE8V9qZo19rlcg3KUNjpxuixg"
    conn = get(conn, session_path(conn, :confirm_email, email: email, key: key))
    assert json_response(conn, 200)["info"]["detail"]
  end

  test "confirmation fails for incorrect key", %{conn: conn} do
    email = "arthur@mail.com"
    key = "pu9-VNdgE8V9QzO19RLCG3KUNjpxuixg"
    conn = get(conn, session_path(conn, :confirm_email, email: email, key: key))
    assert json_response(conn, 401)["errors"]["detail"] =~ "need to login"
  end<% end %>
end
