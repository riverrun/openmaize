defmodule <%= base %>.UserView do
  use <%= base %>.Web, :view<%= if api do %>

  def render("index.json", %{users: users}) do
    %{data: render_many(users, <%= base %>.UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, <%= base %>.UserView, "user.json")}
  end

  def render("info.json", %{info: message}) do
    %{info: %{detail: message}}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      username: user.username}
  end<% end %>
end
