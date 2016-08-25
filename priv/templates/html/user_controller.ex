defmodule <%= base %>.UserController do
  use <%= base %>.Web, :controller

  import <%= base %>.Authorize
  alias <%= base %>.User

  def action(conn, _), do: auth_action conn, __MODULE__

  def index(conn, _params, _user) do
    users = Repo.all(User)
    render(conn, "index.html", users: users)
  end

  def new(conn, _params, _user) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}, user) do
    changeset = User.changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, _user} ->
        auth_info conn, "User created successfully", user_path(conn, :index)
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, _params, user) do
    render(conn, "show.html", user: user)
  end

  def edit(conn, _params, user) do
    changeset = User.changeset(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"user" => user_params}, user) do
    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        auth_info conn, "User updated successfully", user_path(conn, :show, user)
      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, _params, user) do
    Repo.delete!(user)
    auth_info conn, "User deleted successfully", user_path(conn, :index)
  end
end
