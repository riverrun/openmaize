# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Alibaba.Repo.insert!(%Alibaba.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.


users = [
  %{id: 1, username: "gladys", email: "gladys@mail.com", password: "mangoes&g0oseberries"},
  %{id: 2, username: "reg", email: "reg@mail.com", password: "mangoes&g0oseberries"},
  %{id: 3, username: "tony", email: "tony@mail.com", password: "mangoes&g0oseberries"}
]

key = "pu9-VNdgE8V9qZo19rlcg3KUNjpxuixg"
for user <- users do
  %Alibaba.User{}
  |> Alibaba.User.auth_changeset(user, key)
  |> Alibaba.User.reset_changeset(user, key)
  |> Alibaba.Repo.insert!
end
