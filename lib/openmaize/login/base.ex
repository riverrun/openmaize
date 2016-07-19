defmodule Openmaize.Login.Base do
  @moduledoc """
  Module to handle login.
  """

  import Plug.Conn
  alias Openmaize.Config

  @doc """
  Function to handle login.
  """
  def handle_login(conn, user_params, {db_module, uniq_id}) do
    {uniq, user_id, password} = get_params(user_params, uniq_id)
    db_module.find_user(user_id, uniq)
    |> check_pass(password, Config.hash_name)
    |> handle_auth(conn)
  end

  @doc """
  Check the user and password.
  """
  def check_pass(nil, _, _), do: Config.crypto_mod.dummy_checkpw
  def check_pass(%{confirmed_at: nil}, _, _),
    do: {:error, "You have to confirm your email address before continuing."}
  def check_pass(user, password, hash_name) do
    %{^hash_name => hash} = user
    Config.crypto_mod.checkpw(password, hash) and {:ok, user}
  end

  @doc """
  Handle the failure / success of the login and return the `conn`.
  """
  def handle_auth({:ok, %{id: id, otp_required: true}}, conn) do
    put_private(conn, :openmaize_otpdata, id)
  end
  def handle_auth({:ok, %{id: id, role: role}}, conn) do
    put_private(conn, :openmaize_user, %{id: id, role: role})
    |> put_session(:user_id, id)
  end
  def handle_auth({:error, message}, conn) do
    put_private(conn, :openmaize_error, message)
  end
  def handle_auth(_, conn) do
    put_private(conn, :openmaize_error, "Invalid credentials")
  end

  defp get_params(%{"password" => password} = user_params, uniq) when is_atom(uniq) do
    {uniq, Map.get(user_params, to_string(uniq)), password}
  end
  defp get_params(user_params, uniq_func), do: uniq_func.(user_params)
end
