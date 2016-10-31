defmodule Openmaize.ConfirmEmail do
  @moduledoc """
  Confirm a user's email address.

  ## Options

  There are five options:

    * repo - the name of the repo
      * the default is MyApp.Repo - using the name of the project
    * user_model - the name of the user model
      * the default is MyApp.User - using the name of the project
    * key_expires_after - the length, in minutes, that the token is valid for
      * the default is 60 minutes (1 hour)
    * unique_id - the identifier in the query string, or the parameters
      * the default is :email
    * mail_function - the emailing function that you need to define

  ## Email function

  Emailing the end user is the developer's responsibility. If you have
  generated files with the `mix openmaize.gen.phoenixauth --confirm`
  command, then you will have a template at `lib/your_project_name/mailer.ex`.
  You need to complete this template with the mailing library of your
  choice.

  This file, `mailer.ex`, uses the following functions for email confirmation:

    * ask_confirm/2 - send an email with the confirmation link to the user
    * receipt_confirm/1 - send an email stating that the account has been confirmed

  ## Examples with Phoenix

  The easiest way to use this plug is to run the
  `mix openmaize.gen.phoenixauth --confirm` command, which will create
  all the files you need.


  If you do not want to run the above command, you need to add the
  following command to the `web/router.ex` file:

      get "/sessions/confirm_email", SessionController, :confirm_email

  Then add the following to the `session_controller.ex` file:

      plug Openmaize.ConfirmEmail, [mail_function: &Mailer.send_receipt/1] when action in [:confirm]

  """

  import Openmaize.Confirm.Base

  @behaviour Plug

  def init(opts) do
    {Keyword.get(opts, :repo, Openmaize.Utils.default_repo),
    Keyword.get(opts, :user_model, Openmaize.Utils.default_user_model),
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
