defmodule Openmaize.Login.Base do
  @moduledoc """
  """

  @doc false
  defmacro __using__(_) do
    quote do
      @behaviour Plug

      import unquote(__MODULE__)

      @doc false
      def init(opts) do
        {Keyword.get(opts, :repo, Openmaize.Utils.default_repo),
        Keyword.get(opts, :user_model, Openmaize.Utils.default_user_model)}
      end

      @doc false
      def call(%Plug.Conn{params: %{"session" => params}} = conn, opts) do
        check_user_pass conn, unpack_params(params), opts
      end

      def unpack_params(%{"username" => username, "password" => password}) do
        {:username, username, password}
      end
      def unpack_params(%{"email" => email, "password" => password}), do: {:email, email, password}

      defoverridable [init: 1, call: 2, unpack_params: 1]
    end
  end

  import Plug.Conn
  alias Openmaize.Config

  @doc """
  """
  def check_user_pass(conn, {uniq, user_id, password}, {repo, user_model}) do
    repo.get_by(user_model, [{uniq, user_id}])
    |> check_pass(password, Config.hash_name)
    |> handle_auth(conn)
  end

  defp check_pass(nil, _, _), do: Config.crypto_mod.dummy_checkpw
  defp check_pass(%{confirmed_at: nil}, _, _),
    do: {:error, "You have to confirm your email address before continuing."}
  defp check_pass(user, password, hash_name) do
    %{^hash_name => hash} = user
    Config.crypto_mod.checkpw(password, hash) and {:ok, user}
  end

  defp handle_auth({:ok, %{id: id, otp_required: true}}, conn) do
    put_private(conn, :openmaize_otpdata, id)
  end
  defp handle_auth({:ok, user}, conn) do
    put_private(conn, :openmaize_user, user)
  end
  defp handle_auth({:error, message}, conn) do
    put_private(conn, :openmaize_error, message)
  end
  defp handle_auth(_, conn) do
    put_private(conn, :openmaize_error, "Invalid credentials")
  end
end
