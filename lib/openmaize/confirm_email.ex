defmodule Openmaize.ConfirmEmail do
  @moduledoc """
  Confirm a user's email address.

  ## Options

  There are four options:

    * db_module - the module that is used to query the database
      * the default is MyApp.OpenmaizeEcto - the name of the module generated by `mix openmaize.gen.ectodb`
      * if you implement your own database module, it needs to implement the Openmaize.Database behaviour
    * key_expires_after - the length, in minutes, that the token is valid for
      * the default is 60 minutes (1 hour)
    * unique_id - the identifier in the query string, or the parameters
      * the default is :email
    * mail_function - the emailing function that you need to define

  ## Examples

  First, define a `get "/confirm"` route in the web/router.ex file.
  Then, add the following command to the relevant controller file:

      plug Openmaize.ConfirmEmail, [mail_function: &Mailer.send_receipt/1] when action in [:confirm]

  This command will be run when the user accesses the `confirm` route.
  """

  import Openmaize.Confirm.Base

  @behaviour Plug

  def init(opts) do
    {Keyword.get(opts, :db_module, Openmaize.Utils.default_db),
     {Keyword.get(opts, :key_expires_after, 60),
      Keyword.get(opts, :unique_id, :email),
      Keyword.get(opts, :mail_function)}}
  end

  def call(%Plug.Conn{params: %{"key" => key} = user_params} = conn, opts)
  when byte_size(key) == 32 do
    check_user_key(conn, user_params, key, :nopassword, opts)
  end
  def call(conn, _opts), do: invalid_link_error(conn)

  @doc """
  Generate a confirmation token and a link containing the email address
  and the token.

  The link is used to create the url that the user needs to follow to
  confirm the email address.

  The user_id is the actual name or email address of the user, and
  unique_id refers to the type of identifier. For example, if you
  want to use `username=fred` in your link, you need to set the
  unique_id to :username. The default unique_id is :email.
  """
  def gen_token_link(user_id, unique_id \\ :email) do
    key = :crypto.strong_rand_bytes(24) |> Base.url_encode64
    {key, "#{unique_id}=#{URI.encode_www_form(user_id)}&key=#{key}"}
  end
end
