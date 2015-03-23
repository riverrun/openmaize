defmodule Sanction.Login do
  @moduledoc """
  Module to handle password authentication and the generation
  of tokens.
  """

  import Ecto.Query
  import Sanction.Config

  defmodule InvalidCredentialsError do
    @moduledoc "Error raised when username or password is invalid."
    message = "Invalid username or password."
    defexception message: message, plug_status: 401
  end

  @behaviour Plug

  def init(opts), do: opts

  def call(conn, opts) do
    opts |> IO.inspect
    login(id, password)
  end

  def login(id, password) do
    case from(user in user_model,
        where: user.id == ^id,
        select: user)
        |> repo.one
        |> check_user(password) do
      true -> add_token(user, conn, opts)
      _ -> raise InvalidCredentialsError
    end
  end

  @doc """
  Perform a dummy check for no user.
  """
  def check_user(nil, _), do: crypto_mod.dummy_checkpw
  @doc """
  Check the user and user's password.
  """
  def check_user(user, password) do
    crypto_mod.checkpw(password, user.password_hash)
  end

  def add_token(user, conn, opts) do
    opts = Keyword.put_new(opts, :http_only, true)
    put_resp_cookie(conn, "access_token", generate_token(user), opts)
  end

  def generate_token(user) do
    Map.take(user, [:id])
    |> Map.merge(%{exp: token_expiry_secs})
    |> Joken.encode(secret_key)
  end

  defp token_expiry_secs do
    (:calendar.universal_time
    |> :calendar.datetime_to_gregorian_seconds)
    + token_validity
  end 

end
