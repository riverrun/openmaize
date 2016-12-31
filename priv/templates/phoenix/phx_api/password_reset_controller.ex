defmodule <%= base %>.PasswordResetController do
  use <%= base %>.Web, :controller

  import <%= base %>.Authorize
  alias <%= base %>.{Mailer, User}

  plug Openmaize.ResetPassword,
    [mail_function: &Mailer.receipt_confirm/1] when action in [:update]

  def create(conn, %{"password_reset" => %{"email" => email} = user_params}) do
    {key, link} = Openmaize.ConfirmEmail.gen_token_link(email)
    changeset = User.reset_changeset(Repo.get_by(User, email: email), user_params, key)

    case Repo.update(changeset) do
      {:ok, _user} ->
        Mailer.ask_reset(email, link)
        message = "Check your inbox for instructions on how to reset your password"
        conn
        |> put_status(:created)
        |> render("info.json", message: message)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(<%= base %>.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def update(%Plug.Conn{private: %{openmaize_error: message}} = conn,
   %{"id" => user, "password_reset" => %{"email" => email, "key" => key}}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(<%= base %>.ChangesetView, "error.json", error: message)
  end
  def update(%Plug.Conn{private: %{openmaize_info: message}} = conn, _params) do
    conn
    |> put_status(:updated)
    |> render("info.json", message: message)
  end
end
