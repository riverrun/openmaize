defmodule Openmaize.Login do
  @moduledoc """
  Plug to handle login.

  There are five options:

  * redirects - if true, which is the default, redirect on login
  * storage - storage method for the token
    * the default is :cookie
    * if storage is set to nil, redirects is automatically set to false
  * token_validity - length of validity of token (in minutes)
    * the default is 1440 minutes (one day)
  * unique_id - the name which is used to identify the user (in the database)
    * the default is `:name`
  * database_call - a custom function to query the database
    * if you are using Ecto, you will probably not need this

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

  ## Custom function to query the database

  To call a custom query function:

      plug Openmaize.Login, [database_call: &custom_query/3] when action in [:login_user]

  In the above example, this module will use the custom_query function
  instead of LoginTools.check_user.
  """

  import Openmaize.{Report, Token}
  alias Openmaize.LoginTools

  @behaviour Plug

  def init(opts) do
    {redirects, storage} = case Keyword.get(opts, :storage, :cookie) do
             :cookie -> {Keyword.get(opts, :redirects, true), :cookie}
             nil -> {false, nil}
           end
    {redirects, storage, {0, Keyword.get(opts, :token_validity, 1440)},
     Keyword.get(opts, :unique_id, :name),
     Keyword.get(opts, :database_call, &LoginTools.check_user/3)}
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
