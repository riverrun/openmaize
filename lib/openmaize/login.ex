defmodule Openmaize.Login do
  @moduledoc """
  Module to handle password authentication and the generation
  of tokens.
  """

  import Plug.Conn
  import Ecto.Query
  import Openmaize.Tools
  alias Openmaize.Config
  alias Openmaize.Token

  @behaviour Plug

  def init(opts), do: opts

  def call(conn, opts) do
    %{"name" => name, "password" => password} = Map.take(conn.params["user"],
    ["name", "password"])

    case login_user(name, password) do
      false -> redirect_to_login(conn)
      user -> add_token(user, conn, opts, Config.storage_method)
    end
  end

  @doc """
  Check for the user in the database and check the password if the user
  is found.
  """
  def login_user(name, password) do
    from(user in Config.user_model,
    where: user.name == ^name,
    select: user)
    |> Config.repo.one
    |> check_user(password)
  end

  @doc """
  Perform a dummy check for no user.
  """
  def check_user(nil, _), do: Config.get_crypto_mod.dummy_checkpw
  @doc """
  Check the user and user's password.
  """
  def check_user(user, password) do
    Config.get_crypto_mod.checkpw(password, user.password_hash) and user
  end

  @doc """
  Generate a token and store it in a cookie.
  """
  def add_token(user, conn, opts, storage) when storage == "cookie" do
    opts = Keyword.put_new(opts, :http_only, true)
    {:ok, token} = generate_token(user)
    put_resp_cookie(conn, "access_token", token, opts)
    |> redirect_page("/users")
  end
  @doc """
  Generate a token and send it in the response.
  """
  def add_token(user, conn, _opts, _storage) do
    # how can we add the token to sessionStorage?
    token_string = "{\"Authorization\": \"Bearer #{generate_token(user)}\"}"
    send_resp(conn, 200, token_string)
  end

  def generate_token(user) do
    # how can users define what goes in the token?
    Map.take(user, [:id, :name, :role])
    |> Map.merge(%{exp: token_expiry_secs})
    |> Token.encode
  end

  defp token_expiry_secs do
    current_time + Config.token_validity
  end 

  defp current_time do
    {mega, secs, _} = :os.timestamp
    mega * 1000000 + secs
  end
end
