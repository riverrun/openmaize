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

      plug Openmaize.Login when action in [:login_user]

  If you want to use sessionStorage to store the token (this will also set
  redirects to false):

      plug Openmaize.Login, [storage: nil] when action in [:login_user]

  If you want to store the token in sessionStorage and have the token valid
  for just two hours:

      plug Openmaize.Login, [storage: nil, token_validity: 120] when action in [:login_user]

  """

  import Ecto.Query
  import Openmaize.Report
  import Openmaize.Token
  alias Openmaize.Config

  @behaviour Plug

  def init(opts) do
    token_opts = {0, Keyword.get(opts, :token_validity, 1440)}
    case Keyword.get(opts, :storage, :cookie) do
      :cookie -> {Keyword.get(opts, :redirects, true), :cookie, token_opts}
      nil -> {false, nil, token_opts}
    end
  end

  @doc """
  Handle the login POST request.

  If the login is successful, a JSON Web Token will be returned.
  """
  def call(%Plug.Conn{params: %{"user" => user_params}} = conn, opts) do
    user_params |> find_user(Config.unique_id) |> handle_auth(conn, opts)
  end

  defp find_user(user_params, uniq) do
    user = Map.get(user_params, uniq)
    password = Map.get(user_params, "password")
    uniq |> String.to_atom |> check_user(user, password)
  end
  defp check_user(uniq, user, password) do
    from(u in Config.user_model,
         where: field(u, ^uniq) == ^user,
         select: u)
    |> Config.repo.one
    |> check_pass(password)
  end

  defp check_pass(nil, _), do: Config.get_crypto_mod.dummy_checkpw
  defp check_pass(%{confirmable: true, confirmed: false}, _),
    do: Config.get_crypto_mod.dummy_checkpw
  defp check_pass(user, password) do
    Config.get_crypto_mod.checkpw(password, user.password_hash) and user
  end

  defp handle_auth(false, conn, {redirects, _, _}) do
    handle_error(conn, "Invalid credentials", redirects)
  end
  defp handle_auth(user, conn, opts) do
    add_token(conn, user, opts)
  end
end
