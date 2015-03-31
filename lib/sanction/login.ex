defmodule Sanction.Login do
  @moduledoc """
  Module to handle password authentication and the generation
  of tokens.
  """

  import Plug.Conn
  import Ecto.Query
  alias Comeonin.Pbkdf2
  alias Sanction.Config
  alias Sanction.Token

  defmodule InvalidCredentialsError do
    @moduledoc "Error raised when username or password is invalid."
    message = "Invalid username or password."
    defexception message: message, plug_status: 401
  end

  @behaviour Plug

  def init(opts), do: opts

  def call(conn, opts) do
    %{id: id, password: password} = Map.take(conn.params, [:id, :password])
    case login_user(id, password) do
      false -> raise InvalidCredentialsError
      user -> add_token(user, conn, opts)
    end
  end

  @doc """
  Check for the user in the database and check the password if the user
  is found.
  """
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
  def check_user(nil, _), do: Pbkdf2.dummy_checkpw
  @doc """
  Check the user and user's password.
  """
  def check_user(user, password) do
    Pbkdf2.checkpw(password, user.password_hash) and user
  end

  @doc """
  Generate a token and send it in the response.
  """
  def add_token(user, conn, _opts) do
    token_string = "{\"access_token\": \"#{generate_token(user)}\"}"
    send_resp(conn, 200, token_string)
  end

  defp generate_token(user) do
    Token.encode(Map.take(user, [:id]), %{exp: token_expiry_secs})
  end

  defp token_expiry_secs do
    current_time + Config.token_validity
  end 

  defp current_time do
    {mega, secs, _} = :os.timestamp
    mega * 1000000 + secs
  end
end
