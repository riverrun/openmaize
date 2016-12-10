defmodule <%= base %>.TestHelpers do<%= if html == false do %>
  use Phoenix.ConnTest<% end %>
<%= if confirm do %>
  import Ecto.Changeset
<% end %>
  alias <%= base %>.{Repo, User}

  def add_user(username) do
    user = %{username: username, email: "#{username}@mail.com",
     password: "mangoes&g0oseberries"}<%= if confirm do %>
    key = "pu9-VNdgE8V9qZo19rlcg3KUNjpxuixg"<% end %>
    %User{}<%= if confirm do %>
    |> User.auth_changeset(user, key)<% else %>
    |> User.auth_changeset(user)<% end %>
    |> Repo.insert!
  end<%= if confirm do %>

  def add_user_confirmed(username) do
    add_user(username)
    Repo.get_by(User, %{username: username})
    |> change(%{confirmed_at: Ecto.DateTime.utc})
    |> Repo.update!
  end

  def add_reset(username) do
    user = %{username: username, email: "#{username}@mail.com",
     password: "mangoes&g0oseberries"}
    key = "pu9-VNdgE8V9qZo19rlcg3KUNjpxuixg"
    %User{}
    |> User.auth_changeset(user, key)
    |> User.reset_changeset(user, key)
    |> Repo.insert!
  end<% end %>
<%= if html == false do %>
  def add_token_conn(conn, user) do
    user_token = Phoenix.Token.sign(<%= base %>.Endpoint, "user token", user.id)
    conn
    |> put_req_header("accept", "application/json")
    |> put_req_header("authorization", user_token)
  end
<% end %>
end
