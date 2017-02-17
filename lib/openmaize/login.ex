defmodule Openmaize.Login do
  @moduledoc """
  Module to handle login.

  `Openmaize.Login` checks the user's password, making sure that the
  account has been confirmed, if necessary, and returns an `openmaize_user`
  message (the user model) if login is successful or an `openmaize_error`
  message if there is an error.

  After this function has been called, you need to add the user to the
  session, by running `put_session(conn, :user_id, id)`, or send an API
  token to the user. If you are using two-factor authentication, you
  need to first check the user model for `otp_required: true` and, if
  necessary, redirect the user to the one-time password input page.

  ## Options

  There are three options:
    * unique_id - the name which is used to identify the user (in the database)
      * the default is `:email`
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
  but email otherwise.

      def phone_name(%{"email" => email, "password" => password}) do
        {Regex.match?(~r/^[0-9]+$/, email) and :phone || :email, email, password}
      end

  To use this function, add the following to the session controller:

      plug Openmaize.Login, [unique_id: &phone_name/1] when action in [:create]

  """

  @behaviour Plug

  import Plug.Conn
  alias Openmaize.{Config, Log}

  @doc false
  def init(opts) do
    uniq = Keyword.get(opts, :unique_id, :email)
    user_params = if is_atom(uniq), do: to_string(uniq), else: "email"
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

  defp handle_auth({:ok, user}, conn, user_id) do
    Log.log(:info, Config.log_level, conn.request_path,
            %Log{user: user_id, message: "successful login"})
    put_private(conn, :openmaize_user, Map.drop(user, Config.drop_user_keys))
  end
  defp handle_auth({:error, message}, conn, user_id) do
    Log.log(:warn, Config.log_level, conn.request_path, %Log{user: user_id, message: message})
    output = case message do
      "acc" <> _ -> "You have to confirm your account"
      _ -> "Invalid credentials"
    end
    put_private(conn, :openmaize_error, output)
  end
end
