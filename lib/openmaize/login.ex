defmodule Openmaize.Login do
  @moduledoc """
  Module to handle password authentication and the generation, and
  distribution, of tokens.

  If the login is successful, the token will either be stored in a cookie
  or sent back in the body of the response.
  """

  import Ecto.Query
  import Openmaize.Token
  import Openmaize.Report
  alias Openmaize.Config

  @doc """
  Function to handle user login.

  If there is no error, a token will be created and sent to the user so that
  the user can make further requests without logging in again.

  If the option `redirects` is not set, or set to true, the user will then
  be redirected to the main page / user page. If there is an error, the
  user will be redirected to the login page.

  If `redirects` is set to false, then there will be no redirects.

  """
  def call(%Plug.Conn{params: %{"user" => user_params}} = conn, {redirects, storage, token_opts}) do
    user = Map.get(user_params, Config.unique_id)
    password = Map.get(user_params, "password")
    case {login_user(user, password), redirects} do
      {false, false} -> send_error(conn, 401, "Invalid credentials")
      {false, true} -> handle_error(conn, "Invalid credentials")
      {user, _} -> add_token(conn, user, token_opts, storage)
    end
  end

  defp login_user(user, password) do
    uniq = Config.unique_id |> String.to_atom |> IO.inspect
    from(user in Config.user_model,
    #where: user.name == ^user,
    where: field(user, ^uniq) == ^user,
    select: user)
    |> Config.repo.one
    |> check_user(password)
  end

  defp check_user(nil, _), do: Config.get_crypto_mod.dummy_checkpw
  defp check_user(user, password) do
    Config.get_crypto_mod.checkpw(password, user.password_hash) and user
  end
end
