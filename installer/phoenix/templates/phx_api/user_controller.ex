defmodule <%= base %>.UserController do
  use <%= base %>.Web, :controller<%= if confirm do %>

  alias <%= base %>.{Mailer, User}
  alias Openmaize.ConfirmEmail<% else %>
  alias <%= base %>.User<% end %>

  plug :user_check when action in [:index, :show]
  plug :id_check when action in [:update, :delete]

  def index(conn, _params) do
    users = Repo.all(User)
    render(conn, "index.json", users: users)
  end<%= if confirm do %>

  def create(conn, %{"user" => %{"email" => email} = user_params}) do
    {key, link} = ConfirmEmail.gen_token_link(email)
    changeset = User.auth_changeset(%User{}, user_params, key)

    case Repo.insert(changeset) do
      {:ok, user} ->
        Mailer.ask_confirm(email, link)<% else %>

  def create(conn, %{"user" => user_params}) do
    changeset = User.auth_changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} -><% end %>
        conn
        |> put_status(:created)
        |> put_resp_header("location", user_path(conn, :show, user))
        |> render("show.json", user: user)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(<%= base %>.ChangesetView, "error.json", changeset: changeset)
    end
  end

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
    Repo.get!(User, id) |> Repo.delete!
    send_resp(conn, :no_content, "")
  end

  defp user_check(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts) do
    put_status(conn, :unauthorized) |> render(<%= base %>.AuthView, "401.json", []) |> halt
  end
  defp user_check(conn, _opts), do: conn

  defp id_check(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts) do
    put_status(conn, :unauthorized) |> render(<%= base %>.AuthView, "401.json", []) |> halt
  end
  defp id_check(%Plug.Conn{params: %{"id" => id},
                           assigns: %{current_user: current_user_id}} = conn, _opts) do
    id == to_string(current_user_id) and conn ||
    put_status(conn, :forbidden) |> render(<%= base %>.AuthView, "403.json", []) |> halt
  end
end
