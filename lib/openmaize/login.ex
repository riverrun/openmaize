defmodule Openmaize.Login do
  @moduledoc """
  """

  @behaviour Plug

  import Plug.Conn
  alias Openmaize.{Config, Logger}

  def init(opts) do
    uniq = Keyword.get(opts, :unique_id, :username)
    {uniq, to_string(uniq),
    Keyword.get(opts, :repo, Openmaize.Utils.default_repo),
    Keyword.get(opts, :user_model, Openmaize.Utils.default_user_model)}
  end

  def call(%Plug.Conn{params: %{"session" => params}} = conn,
    {uniq, user_params, repo, user_model}) when is_atom(uniq) do
    %{^user_params => user_id, "password" => password} = params
    check_user_pass conn, {uniq, user_id, password}, {repo, user_model}
  end
  def call(%Plug.Conn{params: %{"session" => params}} = conn,
    {uniq, _, repo, user_model}) do
    check_user_pass conn, uniq.(params), {repo, user_model}
  end

  @doc """
  Check the user's password.
  """
  def check_user_pass(conn, {uniq, user_id, password}, {repo, user_model}) do
    repo.get_by(user_model, [{uniq, user_id}])
    |> check_pass(password, Config.hash_name)
    |> handle_auth(conn, user_id)
  end
  def check_user_pass(_, _, _), do: raise ArgumentError, "invalid params or options"

  defp check_pass(nil, _, _) do
    Config.crypto_mod.dummy_checkpw
    {:error, "invalid user-identifier"}
  end
  defp check_pass(%{confirmed_at: nil}, _, _), do: {:error, "account unconfirmed"}
  defp check_pass(user, password, hash_name) do
    %{^hash_name => hash} = user
    Config.crypto_mod.checkpw(password, hash) and
    {:ok, user} || {:error, "invalid password"}
  end

  defp handle_auth({:ok, %{id: id, otp_required: true}}, conn, _) do
    put_private(conn, :openmaize_otpdata, id)
  end
  defp handle_auth({:ok, user}, conn, _) do
    put_private(conn, :openmaize_user, user)
  end
  defp handle_auth({:error, "acc" <> _ = message}, conn, user_id) do
    Logger.warn conn, user_id, message
    put_private(conn, :openmaize_error, "You have to confirm your account")
  end
  defp handle_auth({:error, message}, conn, user_id) do
    Logger.warn conn, user_id, message
    put_private(conn, :openmaize_error, "Invalid credentials")
  end
end
