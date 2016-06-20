defmodule Openmaize.Login.Base do
  @moduledoc """
  Base implementation of the login module.

  This is used by Openmaize.Login.

  You can also use it to create your own custom module / plug.
  """

  @doc false
  defmacro __using__(_) do
    quote do

      @behaviour Plug

      import unquote(__MODULE__)

      def init(opts) do
        {Keyword.get(opts, :storage, :cookie),
         Keyword.get(opts, :unique_id, :username),
         Keyword.get(opts, :add_jwt, &OpenmaizeJWT.Plug.add_token/5),
         Keyword.get(opts, :override_exp)}
      end

      @doc """
      Plug to handle the login POST request.
      """
      def call(%Plug.Conn{params: %{"user" =>
         %{"remember_me" => "true"} = user_params}} = conn, opts) do
        handle_login conn, user_params, opts
      end
      def call(%Plug.Conn{params: %{"user" => user_params}} = conn,
       {storage, uniq_id, add_jwt, _}) do
        handle_login conn, user_params, {storage, uniq_id, add_jwt, nil}
      end

      defoverridable [init: 1, call: 2]
    end
  end

  import Plug.Conn
  alias Openmaize.Config

  @doc """
  Handle the login POST request.

  If the login is successful and `otp_required: true` is not in the
  user model, a JSON Web Token will be added to the conn, either in
  a cookie or in the body of the response. The conn is then returned.

  If `otp_required: true` is in the user model, `conn.private.openmaize_otp_required`
  will be set to true, but no token will be issued yet.
  """
  def handle_login(conn, user_params, {storage, uniq_id, add_jwt, override_exp}) do
    {uniq, user_id, password} = get_params(user_params, uniq_id)
    Config.db_module.find_user(user_id, uniq)
    |> check_pass(password, Config.hash_name)
    |> handle_auth(conn, {storage, uniq, add_jwt, override_exp})
  end

  defp get_params(%{"password" => password} = user_params, uniq) when is_atom(uniq) do
    {uniq, Map.get(user_params, to_string(uniq)), password}
  end
  defp get_params(user_params, uniq_func), do: uniq_func.(user_params)

  defp check_pass(nil, _, _), do: Config.crypto_mod.dummy_checkpw()
  defp check_pass(%{confirmed_at: nil}, _, _),
    do: {:error, "You have to confirm your email address before continuing."}
  defp check_pass(user, password, hash_name) do
    %{^hash_name => hash} = user
    Config.crypto_mod.checkpw(password, hash) and {:ok, user}
  end

  defp handle_auth({:ok, %{id: id, otp_required: true}}, conn,
   {storage, uniq, _, override_exp}) do
    put_private(conn, :openmaize_otpdata, {storage, uniq, id, override_exp})
  end
  defp handle_auth({:ok, user}, conn, {storage, uniq, add_jwt, override_exp}) do
    add_jwt.(conn, user, storage, uniq, override_exp)
  end
  defp handle_auth({:error, message}, conn, _opts) do
    put_private(conn, :openmaize_error, message)
  end
  defp handle_auth(_, conn, _opts) do
    put_private(conn, :openmaize_error, "Invalid credentials")
  end
end
