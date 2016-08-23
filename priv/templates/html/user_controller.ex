defmodule <%= base %>.UserController do
  use <%= base %>.Web, :controller

  import <%= base %>.Authorize
  alias <%= base %>.User

<%= if roles do %>
  def action(conn, _), do: auth_action_role conn, ["admin", "user"], __MODULE__
<% else %>
  def action(conn, _), do: auth_action conn, __MODULE__
<% end %>

  def index(conn, _params, user) do
    users = Repo.all(User)
    render(conn, "index.html", users: users)
  end

  def new(conn, _params, user) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}, user) do
    changeset = User.changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: user_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, user) do
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"id" => id}, user) do
    changeset = User.changeset(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}, user) do
    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: user_path(conn, :show, user))
      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user) do
    Repo.delete!(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: user_path(conn, :index))
  end
end
