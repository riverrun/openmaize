defmodule Openmaize.Login.Base do
  @moduledoc """
  Base module for handling logins.

  This is used by the Openmaize Plug and can also be used to create
  custom Plugs.

  ## Customization

  In this module, the `init/1`, `call/2` and `unpack_params/1` functions
  can all be overriden.

  The following is an example where the user is identified depending on
  the input (phone number or username):

      defmodule MyApp.CustomLogin do
        use Openmaize.Login.Base

        def unpack_params(%{"phone" => phone, "password" => password}) do
          {Regex.match?(~r/^[0-9]+$/, phone) and :phone || :username, phone, password}
        end
        def unpack_params(_), do: nil
      end

  """

  @doc false
  defmacro __using__(_) do
    quote do
      @behaviour Plug

      import unquote(__MODULE__)

      def init(opts) do
        {Keyword.get(opts, :repo, Openmaize.Utils.default_repo),
        Keyword.get(opts, :user_model, Openmaize.Utils.default_user_model)}
      end

      def call(%Plug.Conn{params: %{"session" => params}} = conn, opts) do
        check_user_pass conn, unpack_params(params), opts
      end

      def unpack_params(%{"username" => username, "password" => password}) do
        {:username, username, password}
      end
      def unpack_params(_), do: nil

      defoverridable [init: 1, call: 2, unpack_params: 1]
    end
  end

  import Plug.Conn
  alias Openmaize.{Config, Logger}

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
