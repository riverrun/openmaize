defmodule Openmaize.OnetimePass do
  @moduledoc """
  Module to handle one-time passwords for use in two factor authentication.

  There are three options (these are the same options as for the Login module):

  * storage - store the token in a cookie, which is the default, or not have Openmaize handle the storage
    * if you are developing an api or want to store the token in sessionStorage, set storage to nil
  * unique_id - the name which is used to identify the user (in the database)
    * the default is `:username`
    * this can also be a function which checks the user input and returns an atom
    * see the Openmaize.Login.Name module for some example functions
  * add_jwt - the function used to add the JSON Web Token to the response
    * the default is `&OpenmaizeJWT.Plug.add_token/3`

  """

  import Plug.Conn
  alias Comeonin.Otp
  alias Openmaize.Config

  @behaviour Plug

  def init(opts) do
    {Keyword.get(opts, :storage, :cookie),
     Keyword.get(opts, :unique_id, :username),
     Keyword.get(opts, :add_jwt, &OpenmaizeJWT.Plug.add_token/3), opts}
  end

  @doc """
  Handle the one-time password POST request.

  If the one-time password check is successful, a JSON Web Token will be added
  to the conn, either in a cookie or in the body of the response. The conn
  is then returned.
  """
  def call(%Plug.Conn{params: %{"user" => user_params}} = conn, {storage, uniq, add_jwt, opts}) do
    case Map.get(user_params, to_string(uniq)) do
      nil -> handle_auth({nil, false}, conn, {storage, uniq, add_jwt})
      user_id ->
        Config.db_module.find_user(user_id, uniq)
        |> check_key(user_params, opts)
        |> handle_auth(conn, {storage, uniq, add_jwt})
    end
  end

  def check_key(user, %{"hotp" => hotp}, opts) do
    {user, Otp.check_hotp(hotp, user.otp_secret, opts)}
  end
  def check_key(user, %{"totp" => totp}, opts) do
    {user, Otp.check_totp(totp, user.otp_secret, opts)}
  end

  def handle_auth({_, false}, conn, _opts) do
    put_private(conn, :openmaize_error, "Invalid credentials")
  end
  def handle_auth({user, last}, conn, {storage, uniq, add_jwt}) do
    conn |> put_private(:openmaize_info, last) |> add_jwt.(user, {storage, uniq})
  end
end
