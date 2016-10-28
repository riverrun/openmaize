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

  ## Email function

  Emailing the end user is the developer's responsibility. If you have
  generated files with the `mix openmaize.gen.phoenixauth --confirm`
  command, then you will have a template at `lib/your_project_name/mailer.ex`.
  You need to complete this template with the mailing library of your
  choice.

  This file, `mailer.ex`, uses the following functions for password resetting:

    * ask_reset/2 - send an email with the link to reset the password to the user
    * receipt_confirm/1 - send an email stating that the password has been changed

  ## Examples with Phoenix

  The easiest way to use this plug is to run the
  `mix openmaize.gen.phoenixauth --confirm` command, which will create
  all the files you need.

  If you do not want to run the above command, you need to create the
  following files:

    * controllers/password_reset_controller.ex
    * views/password_reset_view.ex
    * templates/password_reset/new.html.eex
    * templates/password_reset/edit.html.eex

  In the `edit.html.eex` file, make sure that the form uses `password_reset` to
  identify the user.

  You also need to add the following command to the `web/router.ex` file:

      resources "/password_resets", PasswordResetController, only: [:new, :create, :edit, :update]

  Add the following command to the `password_reset_controller.ex` file:

      plug Openmaize.ResetPassword, [mail_function: &Mailer.send_receipt/1] when action in [:reset_password]

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
