defmodule Openmaize.Login do
  @moduledoc """
  Module to handle login.

  There are three options:

    * repo - the name of the repo
      * the default is MyApp.Repo - using the name of the project
    * user_model - the name of the user model
      * the default is MyApp.User - using the name of the project
    * unique_id - the name which is used to identify the user (in the database)
      * the default is `:username`
      * this can also be a function which checks the user input and returns an atom
        * see the Openmaize.Login.Name module for some example functions

  ## Examples with Phoenix

  The easiest way to use this plug is to run the
  `mix openmaize.gen.phoenixauth` command, which will create
  all the files you need.

  If you do not want to run the above command, you need to create the
  following files:

    * controllers/session_controller.ex
    * views/session_view.ex
    * templates/session/new.html.eex

  In the `new.html.eex` file, make sure that the form uses `session` to
  identify the user.

  You also need to add the following command to the `web/router.ex` file:

      resources "/sessions", SessionController, only: [:new, :create, :delete]

  Add the following command to the `session_controller.ex` file:

      plug Openmaize.Login when action in [:login_user]

  If you want to use `email` to identify the user:

      plug Openmaize.Login, [unique_id: :email] when action in [:login_user]

  If you want to use `email` or `username` to identify the user (allowing the
  end user a choice):

      plug Openmaize.Login, [unique_id: &Openmaize.Login.Name.email_username/1] when action in [:login_user]

  """

  @behaviour Plug

  import Plug.Conn
  alias Openmaize.Config

  def init(opts) do
    {Keyword.get(opts, :repo, Openmaize.Utils.default_repo),
    Keyword.get(opts, :user_model, Openmaize.Utils.default_user_model),
    Keyword.get(opts, :unique_id, :username)}
  end

  @doc """
  Handle the login POST request.

  If the login is successful and `otp_required: true` is not in the
  user model, the user will be added to the `conn.private.openmaize_user`
  value. You can then use the information in the user model to add
  the user to the session.

  If the login is unsuccessful, an error message will be added to
  `conn.private.openmaize_error`.

  ## Two factor authentication

  If `otp_required: true` is in the user model and if the login is
  successful, `conn.private.openmaize_otpdata` will be set to the
  user id.

  ## User email confirmation

  Before checking the password, the user struct will be checked for a
  `confirmed_at` value. If it is set to nil, an error message will be
  added to `conn.private.openmaize_error`.
  """
  def call(%Plug.Conn{params: %{"session" => user_params}} = conn,
   {repo, user_model, uniq_id}) do
    {uniq, user_id, password} = get_params(user_params, uniq_id)
    repo.get_by(user_model, [{uniq, user_id}])
    |> check_pass(password, Config.hash_name)
    |> handle_auth(conn)
  end

  defp get_params(%{"password" => password} = user_params, uniq) when is_atom(uniq) do
    {uniq, Map.get(user_params, to_string(uniq)), password}
  end
  defp get_params(user_params, uniq_func), do: uniq_func.(user_params)

  defp check_pass(nil, _, _), do: Config.crypto_mod.dummy_checkpw
  defp check_pass(%{confirmed_at: nil}, _, _),
    do: {:error, "You have to confirm your email address before continuing."}
  defp check_pass(user, password, hash_name) do
    %{^hash_name => hash} = user
    Config.crypto_mod.checkpw(password, hash) and {:ok, user}
  end

  defp handle_auth({:ok, %{id: id, otp_required: true}}, conn) do
    put_private(conn, :openmaize_otpdata, id)
  end
  defp handle_auth({:ok, user}, conn) do
    put_private(conn, :openmaize_user, user)
  end
  defp handle_auth({:error, message}, conn) do
    put_private(conn, :openmaize_error, message)
  end
  defp handle_auth(_, conn) do
    put_private(conn, :openmaize_error, "Invalid credentials")
  end
end
