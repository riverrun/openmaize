defmodule <%= base %>.PasswordResetController do
  use <%= base %>.Web, :controller

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
        conn
        |> put_flash(:info, "Check your inbox for instructions on how to reset your password.")
        |> redirect(to: page_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"email" => email, "key" => key}) do
    render conn, "edit.html", email: email, key: key
  end

  def update(%Plug.Conn{private: %{openmaize_error: message}} = conn,
   %{"user" => %{"email" => email, "key" => key}}) do
    conn
    |> put_flash(:error, message)
    |> render("reset_form.html", email: email, key: key)
  end
  def update(%Plug.Conn{private: %{openmaize_info: message}} = conn, _params) do
    conn
    |> configure_session(drop: true)
    |> put_flash(:info, message)
    |> redirect(to: "/login")
  end
end
