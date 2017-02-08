defmodule Openmaize.Login do
  @moduledoc """
  Module to handle login.

  `Openmaize.Login` checks the user's password, making sure that the
  account has been confirmed, if necessary, and returns an `openmaize_user`
  message if login is successful (unless you are using two-factor authentication)
  or an `openmaize_error` message if there is an error.

  ## Two-factor authentication

  If two-factor authentication is enabled and `otp_required` for the
  user is true, an `openmaize_otpdata` message is returned. This contains
  the user id, which is then used when authenticating the one-time
  password.

  ## Options

  There are three options:
    * unique_id - the name which is used to identify the user (in the database)
      * the default is `:username`
      * this can also be a function - see below for an example
    * repo - the name of the repo
      * the default is MyApp.Repo - using the name of the project
    * user_model - the name of the user model
      * the default is MyApp.User - using the name of the project

  ### unique_id option

  The `unique_id` option is usually an atom, but it can also be a function
  which returns a tuple with the {unique_id (as an atom), user_id, password}.

  The following example is a function that takes the user parameters as
  input and searches for the user by phone number if the input is all digits,
  but username otherwise.

      def phone_name(%{"username" => username, "password" => password}) do
        {Regex.match?(~r/^[0-9]+$/, username) and :phone || :username, username, password}
      end

  To use this function, add the following to the session controller:

      plug Openmaize.Login, [unique_id: &phone_name/1] when action in [:create]

  """

  @behaviour Plug

  import Plug.Conn
  alias Openmaize.{Config, Logger}

  @doc false
  def init(opts) do
    uniq = Keyword.get(opts, :unique_id, :username)
    user_params = if is_atom(uniq), do: to_string(uniq), else: "username"
    {uniq, user_params,
    Keyword.get(opts, :repo, Openmaize.Utils.default_repo),
    Keyword.get(opts, :user_model, Openmaize.Utils.default_user_model)}
  end

  @doc false
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

  Search for the user in the database and check the password against
  the stored password hash.

  If no user is found, a dummy hash function is run in order to make
  user enumeration more difficult.
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
