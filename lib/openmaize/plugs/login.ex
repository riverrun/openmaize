defmodule Openmaize.Login do
  @moduledoc """
  Plug to handle login.

  There are four options:

  * redirects - if true, which is the default, redirect on login
  * storage - storage method for the token
    * the default is :cookie
    * if storage is set to nil, redirects is automatically set to false
  * token_validity - length the token is valid for (in minutes)
    * the default is 120 minutes (2 hours)
  * unique_id - the name which is used to identify the user (in the database)
    * the default is `:username`
    * this can also be a function which checks the user input and returns an atom
      * see the Openmaize.LoginTools module for some example functions

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

  If you want to use `email` or `username` to identify the user (allowing the
  end user a choice):

      plug Openmaize.Login, [unique_id: &Openmaize.LoginTools.email_username/1] when action in [:login_user]

  """

  import Openmaize.{Report, Token}
  alias Openmaize.Config

  @behaviour Plug

  def init(opts) do
    {redirects, storage} = case Keyword.get(opts, :storage, :cookie) do
             :cookie -> {Keyword.get(opts, :redirects, true), :cookie}
             nil -> {false, nil}
           end
    {redirects, storage, {0, Keyword.get(opts, :token_validity, 120)},
     Keyword.get(opts, :unique_id, :username)}
  end

  @doc """
  Handle the login POST request.

  If the login is successful, a JSON Web Token will be returned.
  """
  def call(%Plug.Conn{params: %{"user" => user_params}} = conn,
           {redirects, storage, token_opts, uniq_id}) do
    {uniq, user_id, password} = get_params(user_params, uniq_id)
    Config.db_module.find_user(user_id, uniq)
    |> check_pass(password, Config.hash_name)
    |> handle_auth(conn, {redirects, storage, token_opts, uniq})
  end

  defp get_params(%{"password" => password} = user_params, uniq) when is_atom(uniq) do
    {uniq, Map.get(user_params, to_string(uniq)), password}
  end
  defp get_params(user_params, uniq_func), do: uniq_func.(user_params)

  defp check_pass(nil, _, _), do: Config.get_crypto_mod.dummy_checkpw
  defp check_pass(%{confirmed_at: nil}, _, _),
    do: {:error, "You have to confirm your email address before continuing."}
  defp check_pass(user, password, hash_name) do
    %{^hash_name => hash} = user
    Config.get_crypto_mod.checkpw(password, hash) and user
  end

  defp handle_auth(false, conn, {redirects, _, _, _}) do
    put_message(conn, %{"error" => "Invalid credentials"}, redirects)
  end
  defp handle_auth({:error, message}, conn, {redirects, _, _, _}) do
    put_message(conn, %{"error" => message}, redirects)
  end
  defp handle_auth(user, conn, opts) do
    add_token(conn, user, opts)
  end
end
