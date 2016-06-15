defmodule Openmaize.OnetimePass do
  @moduledoc """
  Module to handle one-time passwords for use in two factor authentication.

  There is one option

    * add_jwt - the function used to add the JSON Web Token to the response
      * the default is `&OpenmaizeJWT.Plug.add_token/5`

  """

  import Plug.Conn
  alias Comeonin.Otp
  alias Openmaize.Config

  @behaviour Plug

  def init(opts) do
    Keyword.pop opts, :add_jwt, &OpenmaizeJWT.Plug.add_token/5
  end

  @doc """
  Handle the one-time password POST request.

  If the one-time password check is successful, a JSON Web Token will be added
  to the conn, either in a cookie or in the body of the response. The conn
  is then returned.
  """
  def call(%Plug.Conn{params: %{"user" => user_params}} = conn, {add_jwt, opts}) do
    {storage, uniq, id, override_exp} = get_params(user_params)
    Config.db_module.find_user_byid(id)
    |> check_key(user_params, opts)
    |> handle_auth(conn, {storage, uniq, add_jwt, override_exp})
  end

  defp get_params(%{"storage" => storage, "uniq" => uniq, "id" => id} = user_params) do
    override_exp = Map.get user_params, "override_exp"
    {String.to_atom(storage), String.to_atom(uniq), id,
     override_exp && String.to_integer(override_exp)}
  end

  defp check_key(user, %{"hotp" => hotp}, opts) do
    {user, Otp.check_hotp(hotp, user.otp_secret, opts)}
  end
  defp check_key(user, %{"totp" => totp}, opts) do
    {user, Otp.check_totp(totp, user.otp_secret, opts)}
  end

  defp handle_auth({_, false}, conn, _opts) do
    put_private(conn, :openmaize_error, "Invalid credentials")
  end
  defp handle_auth({user, last}, conn, {storage, uniq, add_jwt, override_exp}) do
    conn
    |> put_private(:openmaize_info, last)
    |> add_jwt.(user, storage, uniq, override_exp)
  end
end
