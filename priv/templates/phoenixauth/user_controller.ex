defmodule <%= base %>.UserController do
  use <%= base %>.Web, :controller

<%= if not api do %>
  import <%= base %>.Authorize<% end %><%= if confirm do %>
  alias <%= base %>.{Mailer, User}
  alias Openmaize.ConfirmEmail<% else %>
  alias <%= base %>.User<% end %>

  plug :user_check when action in [:index, :show]<%= if api do %>
  plug :id_check when action in [:update, :delete]<% else %>
  plug :id_check when action in [:edit, :update, :delete]<% end %>

  def index(conn, _params) do
    users = Repo.all(User)<%= if api do %>
    render(conn, "index.json", users: users)<% else %>
    render(conn, "index.html", users: users)<% end %>
  end<%= if not api do %>

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end<% end %><%= if confirm do %>

  def create(conn, %{"user" => %{"email" => email} = user_params}) do
    {key, link} = ConfirmEmail.gen_token_link(email)
    changeset = User.auth_changeset(%User{}, user_params, key)

    case Repo.insert(changeset) do
      {:ok, _user} ->
        Mailer.ask_confirm(email, link)<% else %>

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, _user} -><% end %><%= if api do %>
        conn
        |> put_status(:created)
        |> put_resp_header("location", user_path(conn, :show, user))
        |> render("show.json", user: user)<% else %>
        auth_info conn, "User created successfully", user_path(conn, :index)<% end %>
      {:error, changeset} -><%= if api do %>
        conn
        |> put_status(:unprocessable_entity)
        |> render(<%= base %>.ChangesetView, "error.json", changeset: changeset)<% else %>
        render(conn, "new.html", changeset: changeset)<% end %>
    end
  end<%= if api do %>

  def show(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        render(conn, "show.json", user: user)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(<%= base %>.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    Repo.delete!(user)

    send_resp(conn, :no_content, "")
  end<% else %>

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
  end<% end %>
end
