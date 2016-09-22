defmodule <%= base %>.PasswordResetController do
  use <%= base %>.Web, :controller

  import <%= base %>.Authorize
  alias <%= base %>.{Mailer, User}

  plug Openmaize.ResetPassword,
    [mail_function: &Mailer.receipt_confirm/1] when action in [:update]

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, %{"user" => %{"email" => email} = user_params}) do
    {key, link} = Openmaize.ConfirmEmail.gen_token_link(email)
    changeset = User.reset_changeset(Repo.get_by(User, email: email), user_params, key)

    case Repo.update(changeset) do
      {:ok, _user} ->
        Mailer.ask_reset(email, link)
        message = "Check your inbox for instructions on how to reset your password"
        auth_info conn, message, user_path(conn, :index)
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"email" => email, "key" => key}) do
    user = Repo.get_by(User, email: email)
    render conn, "edit.html", user: user, email: email, key: key
  end

  def update(%Plug.Conn{private: %{openmaize_error: message}} = conn,
   %{"id" => user, "password_reset" => %{"email" => email, "key" => key}}) do
    conn
    |> put_flash(:error, message)
    |> render("edit.html", user: user, email: email, key: key)
  end
  def update(%Plug.Conn{private: %{openmaize_info: message}} = conn, _params) do
    configure_session(conn, drop: true) |> auth_info(message, session_path(conn, :new))
  end
end
