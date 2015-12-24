defmodule Openmaize.LoginoutCheck do
  @moduledoc """
  Plug to handle login and logout requests.

  This module checks if the path is for the login or logout page and handles the
  login or logout if necessary. If the path is different, the connection is
  returned without any further checks being performed.

  If the path ends with `login` and it is a GET request, the current_user
  is set to nil and the user is sent straight to the login page. If the path
  ends with `login` and it is a POST request, Openmaize processes the login
  request and then, if successful, sends a token back to the user, either
  stored in a cookie or sent in the response body. If `redirects` is set to
  true, the user is redirected to the user's role's page.

  If the path ends with `logout` and the token is stored in a cookie, then
  the cookie is deleted. If `redirects` is set to true, the user is then
  redirected to the home page.

  There are three options:

  * redirects - if true, which is the default, redirect on login / logout
  * storage - storage method for the token -- the default is :cookie
  If redirects is set to false, storage is automatically set to nil
  * token_validity - length of validity of token (in minutes) -- the default is 1440 minutes (one day)

  ## Examples

  Call LoginoutCheck without any options:

      plug Openmaize.LoginoutCheck

  Call LoginoutCheck and send the token in the response body:

      plug Openmaize.LoginoutCheck, storage: nil

  Call LoginoutCheck without redirects:

      plug Openmaize.LoginoutCheck, redirects: false

  Call LoginoutCheck and set the token validity to two hours:

      plug Openmaize.LoginoutCheck, token_validity: 120

  """

  import Plug.Conn
  import Ecto.Query
  import Openmaize.Report
  import Openmaize.Token
  alias Openmaize.Config

  @behaviour Plug

  def init(opts), do: opts

  @doc """
  Check the path and handle login or logout if necessary. If the path
  is not for the login or logout page, the connection is returned.
  """
  def call(%Plug.Conn{path_info: path_info} = conn, opts) do
    {redirects, storage} = case Keyword.get(opts, :redirects, true) do
                             true -> {true, Keyword.get(opts, :storage, :cookie)}
                             false -> {false, nil}
                           end
    token_opts = {0, Keyword.get(opts, :token_validity, 1440)}
    case Enum.at(path_info, -1) do
      "login" -> handle_login(conn, {redirects, storage, token_opts})
      "logout" -> handle_logout(conn, storage)
      _ -> conn
    end
  end

  defp handle_login(%Plug.Conn{method: "POST", params: %{"user" => user_params}} = conn, opts) do
    user_params |> find_user(Config.unique_id) |> handle_auth(conn, opts)
  end
  defp handle_login(conn, _opts) do
    conn |> assign(:current_user, nil) |> put_private(:openmaize_skip, true)
  end

  defp find_user(%{"name" => user, "password" => password}, uniq) do
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
  defp handle_auth(user, conn, {_, storage, token_opts}) do
    add_token(conn, user, token_opts, storage)
  end

  defp handle_logout(conn, storage),
    do: assign(conn, :current_user, nil) |> logout_user(storage)

  defp logout_user(conn, nil), do: conn
  defp logout_user(conn, :cookie) do
    delete_resp_cookie(conn, "access_token")
    |> handle_info("You have been logged out")
  end
end
