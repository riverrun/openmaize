defmodule Openmaize.Login do
  @moduledoc """
  Plug to handle login.

  ## Examples

  """

  import Ecto.Query
  import Openmaize.Report
  import Openmaize.Token
  alias Openmaize.Config

  @behaviour Plug

  def init(opts), do: opts

  @doc """
  Handle the login POST request.
  """
  def call(%Plug.Conn{params: %{"user" => user_params}} = conn, opts) do
    {redirects, storage} = case Keyword.get(opts, :redirects, true) do
                             true -> {true, Keyword.get(opts, :storage, :cookie)}
                             false -> {false, nil}
                           end
    token_opts = {0, Keyword.get(opts, :token_validity, 1440)}
    user_params
    |> find_user(Config.unique_id)
    |> handle_auth(conn, {redirects, storage, token_opts})
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

end
