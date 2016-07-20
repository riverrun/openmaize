defmodule Openmaize.Login.Base do
  @moduledoc """
  Module to handle login.
  """

  import Plug.Conn
  alias Openmaize.Config

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
end
