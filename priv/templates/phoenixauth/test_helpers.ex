defmodule <%= base %>.TestHelpers do

  import Ecto.Changeset
  alias <%= base %>.{Repo, User}

  def add_user(username) do
    user = %{username: username, email: "#{username}@mail.com",
     password: "mangoes&g0oseberries"}
    key = "pu9-VNdgE8V9qZo19rlcg3KUNjpxuixg"
    %User{}
    |> User.auth_changeset(user, key)
    |> Repo.insert!
  end

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
  end

end
