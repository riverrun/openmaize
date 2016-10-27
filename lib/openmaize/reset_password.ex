defmodule Openmaize.ResetPassword do
  @moduledoc """
  Confirm a user's email address and reset the password.

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

  ## Reset password form

  This function is to be used with the `reset` post request. For the
  `reset` get request, you need to render a form with the name "user",
  using `[as: :user]` if you are using Phoenix's `form_for` function,
  which contains values for the password, email and key (the email and
  key should be hidden inputs).

  Before hashing the user's password and adding the hash to the database,
  it is checked to make sure that it is long enough and, if you have
  NotQwerty123 installed, not too weak.

  ## Examples

  First, define a `post "/reset", SomeController, :reset_password` route
  in the web/router.ex file. Then, add the following command to the
  relevant controller file:

      plug Openmaize.ResetPassword, [mail_function: &Mailer.send_receipt/1] when action in [:reset_password]

  This command will be run when the user sends the form with the data to
  reset the password. You will need to write a function to handle the
  `get "/reset"` request, that is, to render the form to reset the password.
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

  def call(%Plug.Conn{params: %{"password_reset" =>
     %{"key" => key, "password" => password} = user_params}} = conn, opts)
  when byte_size(key) == 32 do
    check_user_key(conn, user_params, key, password, opts)
  end
  def call(conn, _opts), do: invalid_link_error(conn)
end
