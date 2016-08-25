defmodule UserHelper do

  alias <%= base %>.{Repo, User}

  @users [
    %{id: 1, username: "gladys", email: "gladys@mail.com", password: "mangoes&g0oseberries"},
    %{id: 2, username: "reg", email: "reg@mail.com", password: "mangoes&g0oseberries"},
    %{id: 3, username: "tony", email: "tony@mail.com", password: "mangoes&g0oseberries"}
  ]

  def add_users do
    key = "pu9-VNdgE8V9qZo19rlcg3KUNjpxuixg"
    for user <- @users do
      %User{}
      |> User.auth_changeset(user, key)
      |> User.reset_changeset(user, key)
      |> Repo.insert!
    end
  end

end
