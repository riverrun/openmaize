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

  If `redirects` is set to false, then obviously there will be no redirects.

  """
  def call(%Plug.Conn{params: params} = conn, {false, _}) do
    %{"name" => user, "password" => password} =
    Map.take(params, ["name", "password"])
    case login_user(user, password) do
      false -> send_error(conn, 401, "Invalid credentials")
      user -> add_token(conn, user, nil)
    end
  end
  def call(%Plug.Conn{params: params} = conn, {_, storage}) do
    %{"name" => user, "password" => password} =
    Map.take(params["user"], ["name", "password"])
    case login_user(user, password) do
      false -> handle_error(conn, "Invalid credentials")
      user -> add_token(conn, user, storage)
    end
  end

  defp login_user(user, password) do
    from(user in Config.user_model,
    where: user.name == ^user,
    select: user)
    |> Config.repo.one
    |> check_user(password)
  end

  defp check_user(nil, _), do: Config.get_crypto_mod.dummy_checkpw
  defp check_user(user, password) do
    Config.get_crypto_mod.checkpw(password, user.password_hash) and user
  end
end
