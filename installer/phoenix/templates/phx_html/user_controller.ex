defmodule <%= base %>.UserController do
  use <%= base %>.Web, :controller

  import <%= base %>.Authorize<%= if confirm do %>
  alias <%= base %>.{Mailer, User}
  alias Openmaize.ConfirmEmail<% else %>
  alias <%= base %>.User<% end %>

  plug :user_check when action in [:index, :show]
  plug :id_check when action in [:edit, :update, :delete]

  def index(conn, _params) do
    users = Repo.all(User)
    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end<%= if confirm do %>

  def create(conn, %{"user" => %{"email" => email} = user_params}) do
    {key, link} = ConfirmEmail.gen_token_link(email)
    changeset = User.auth_changeset(%User{}, user_params, key)

    case Repo.insert(changeset) do
      {:ok, _user} ->
        Mailer.ask_confirm(email, link)<% else %>

  def create(conn, %{"user" => user_params}) do
    changeset = User.auth_changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, _user} -><% end %>
        auth_info conn, "User created successfully", user_path(conn, :index)
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(%Plug.Conn{assigns: %{current_user: user}} = conn, _params) do
    render(conn, "show.html", user: user)
  end

  def edit(%Plug.Conn{assigns: %{current_user: user}} = conn, _params) do
    changeset = User.changeset(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"user" => user_params}) do
    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        auth_info conn, "User updated successfully", user_path(conn, :show, user)
      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(%Plug.Conn{assigns: %{current_user: user}} = conn, _params) do
    Repo.delete!(user)
    configure_session(conn, drop: true)
    |> auth_info("User deleted successfully", page_path(conn, :index))
  end
end
