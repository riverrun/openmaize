defmodule Sanction.Login do
  @moduledoc """
  Module to handle password authentication and the generation
  of tokens.
  """

  import Plug.Conn
  import Ecto.Query
  alias Sanction.Config

  defmodule InvalidCredentialsError do
    @moduledoc "Error raised when username or password is invalid."
    message = "Invalid username or password."
    defexception message: message, plug_status: 401
  end

  @behaviour Plug

  def init(opts), do: opts

  def call(conn, opts) do
    id = conn.params["id"]
    password = conn.params["password"]
    case login_user(id, password) do
      false -> raise InvalidCredentialsError
      user -> add_token(user, conn, opts)
    end
  end

  def login_user(id, password) do
    from(user in Config.user_model,
    where: user.id == ^id,
    select: user)
    |> Config.repo.one
    |> check_user(password)
  end

  @doc """
  Perform a dummy check for no user.
  """
  def check_user(nil, _), do: Config.crypto_mod.dummy_checkpw
  @doc """
  Check the user and user's password.
  """
  def check_user(user, password) do
    Config.crypto_mod.checkpw(password, user.password_hash) and user
  end

  def add_token(user, conn, opts) do
    opts = Keyword.put_new(opts, :http_only, true)
    put_resp_cookie(conn, "access_token", generate_token(user), opts)
  end

  def generate_token(user) do
    Map.take(user, [:id])
    |> Map.merge(%{exp: token_expiry_secs})
    |> Joken.encode(Config.secret_key)
  end

  defp token_expiry_secs do
    (:calendar.universal_time
    |> :calendar.datetime_to_gregorian_seconds)
    + Config.token_validity
  end 

end
