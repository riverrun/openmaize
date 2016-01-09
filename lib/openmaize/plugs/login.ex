defmodule Openmaize.Login do
  @moduledoc """
  Plug to handle login.

  There are three options:

  * redirects - if true, which is the default, redirect on login
  * storage - storage method for the token
    * the default is :cookie
    * if storage is set to nil, redirects is automatically set to false
  * token_validity - length of validity of token (in minutes)
    * the default is 1440 minutes (one day)

  ## Examples with Phoenix

  In the `web/router.ex` file, add the following line (you can use
  a different controller and route):

      post "/login", PageController, :login_user

  And then in the `page_controller.ex` file, add:

      use Openmaize.Login

      plug login when action in [:login_user]

  If you want to use sessionStorage to store the token (this will also set
  redirects to false):

      plug login, [storage: nil] when action in [:login_user]

  If you want to store the token in sessionStorage and have the token valid
  for just two hours:

      plug login, [storage: nil, token_validity: 120] when action in [:login_user]

  ## Overriding these functions

  The `login/2`, `check_user/3`, `check_pass/2` and `handle_auth/3` functions can
  be overridden.

  In the following example, errors are handled differently:

      use Openmaize.Login

      def handle_auth(false, conn, {redirects, _, _, _}) do
        halt(conn)
        IO.puts "Oh no, we're going to crash!!!"
      end

  """

  defmacro __using__(_) do
    quote do

      import Ecto.Query
      import Openmaize.{Report, Token}
      alias Openmaize.Config

      @doc """
      Handle the login POST request.

      If the login is successful, a JSON Web Token will be returned.
      """
      def login(%Plug.Conn{params: %{"user" => user_params}} = conn, opts) do
        token_opts = {0, Keyword.get(opts, :token_validity, 1440)}
        uniq = Keyword.get(opts, :unique_id, :name)
        opts = case Keyword.get(opts, :storage, :cookie) do
                 :cookie -> {Keyword.get(opts, :redirects, true), :cookie, token_opts, uniq}
                 nil -> {false, nil, token_opts, uniq}
               end
        check_user(uniq, to_string(uniq), user_params) |> handle_auth(conn, opts)
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

      defoverridable [login: 2, check_user: 3, check_pass: 2, handle_auth: 3]
    end
  end
end
