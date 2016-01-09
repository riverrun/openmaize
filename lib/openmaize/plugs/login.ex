defmodule Openmaize.Login do
  @moduledoc """
  Plug to handle login.

  There are four options:

  * redirects - if true, which is the default, redirect on login
  * storage - storage method for the token
    * the default is :cookie
    * if storage is set to nil, redirects is automatically set to false
  * token_validity - length of validity of token (in minutes)
    * the default is 1440 minutes (one day)
  * unique_id - the name which is used to identify the user (in the database)
    * the default is `:name`

  ## Examples with Phoenix

  In the `web/router.ex` file, add the following line (you can use
  a different controller and route):

      post "/login", PageController, :login_user

  And then in the `page_controller.ex` file, add:

      plug Openmaize.Login when action in [:login_user]

  If you want to use sessionStorage to store the token (this will also set
  redirects to false):

      plug Openmaize.Login, [storage: nil] when action in [:login_user]

  If you want to use `email` to identify the user and have the token valid
  for just two hours:

      plug Openmaize.Login, [token_validity: 120, unique_id: :email] when action in [:login_user]

  """

  import Ecto.Query
  import Openmaize.{Report, Token}
  alias Openmaize.Config

  @behaviour Plug

  def init(opts) do
    {redirects, storage} = case Keyword.get(opts, :storage, :cookie) do
             :cookie -> {Keyword.get(opts, :redirects, true), :cookie}
             nil -> {false, nil}
           end
    {redirects, storage, {0, Keyword.get(opts, :token_validity, 1440)},
     Keyword.get(opts, :unique_id, :name),
     Keyword.get(opts, :database_call, &check_user/3)}
  end

  @doc """
  Handle the login POST request.

  If the login is successful, a JSON Web Token will be returned.
  """
  def call(%Plug.Conn{params: %{"user" => user_params}} = conn,
           {redirects, storage, token_opts, uniq, db_call}) do
    db_call.(uniq, to_string(uniq), user_params)
    |> handle_auth(conn, {redirects, storage, token_opts, uniq})
  end

  @doc """
  Find the user in the database and check the password.
  """
  def check_user(uniq, unique, user_params) do
    %{^unique => user, "password" => password} = user_params
    from(u in Config.user_model,
         where: field(u, ^uniq) == ^user,
         select: u)
    |> Config.repo.one
    |> check_pass(password)
  end

  @doc """
  Check the password with the user's stored password hash.
  """
  def check_pass(nil, _), do: Config.get_crypto_mod.dummy_checkpw
  def check_pass(%{confirmed: false}, _),
  do: {:error, "You have to confirm your email address before continuing."}
  def check_pass(user, password) do
    Config.get_crypto_mod.checkpw(password, user.password_hash) and user
  end

  @doc """
  Either call the function to create the token or handle the error.
  """
  def handle_auth(false, conn, {redirects, _, _, _}) do
    handle_error(conn, "Invalid credentials", redirects)
  end
  def handle_auth({:error, message}, conn, {redirects, _, _, _}) do
    handle_error(conn, message, redirects)
  end
  def handle_auth(user, conn, opts) do
    add_token(conn, user, opts)
  end
end
