defmodule Openmaize.Login do
  @moduledoc """
  Plug to handle login.

  There are two options:

  * api - if false, which is the default, redirect on login and store the token in a cookie
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

  If you are developing an api:

      plug Openmaize.Login, [api: true] when action in [:login_user]

  If you want to use `email` to identify the user:

      plug Openmaize.Login, [unique_id: :email] when action in [:login_user]

  If you want to use `email` or `username` to identify the user (allowing the
  end user a choice):

      plug Openmaize.Login, [unique_id: &Openmaize.LoginTools.email_username/1] when action in [:login_user]

  """

  import Plug.Conn
  import Openmaize.{Redirect, Token}
  alias Openmaize.Config

  @behaviour Plug

  def init(opts) do
    {redirects, storage} = case Keyword.get(opts, :api, false) do
                             true -> {false, nil}
                             false -> {true, :cookie}
                           end
    {redirects, storage, Keyword.get(opts, :unique_id, :username)}
  end

  @doc """
  Handle the login POST request.

  If the login is successful, a JSON Web Token will be returned.
  If the option `api` is set to false, the JWT will be stored in
  a cookie, and the user will be redirected to the page for that
  user's role. If `api` is set to true, the JWT will be returned
  in the body of the response.
  """
  def call(%Plug.Conn{params: %{"user" => user_params}} = conn,
           {redirects, storage, uniq_id}) do
    {uniq, user_id, password} = get_params(user_params, uniq_id)
    Config.db_module.find_user(user_id, uniq)
    |> check_pass(password, Config.hash_name)
    |> handle_auth(conn, {redirects, storage, uniq})
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
    Config.get_crypto_mod.checkpw(password, hash) and {:ok, user}
  end

  defp handle_auth({:ok, user}, conn, opts) do
    add_token(conn, user, opts)
  end
  defp handle_auth(_, conn, {true, _, _}) do
    redirect_to(conn, "#{Config.redirect_pages["login"]}", %{"error" => "Invalid credentials"})
  end
  defp handle_auth(_, conn, {false, _, _}) do
    send_resp(conn, 401, Poison.encode!(%{"error" => "Invalid credentials"})) |> halt()
  end
end
