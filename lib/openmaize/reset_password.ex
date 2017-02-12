defmodule Openmaize.ResetPassword do
  @moduledoc """
  Confirm a user's email address and reset the password.

  ## Options

  There are four options:

    * repo - the name of the repo
      * the default is MyApp.Repo - using the name of the project
    * user_model - the name of the user model
      * the default is MyApp.User - using the name of the project
    * key_expires_after - the length, in minutes, that the token is valid for
      * the default is 60 minutes (1 hour)
    * mail_function - the emailing function that you need to define

  ## Email function

  Emailing the end user is the developer's responsibility. If you have
  generated files with the `mix openmaize.phx --confirm`
  command, then you will have a template at `lib/your_project_name/mailer.ex`.
  You need to complete this template with the mailing library of your
  choice.

  ## Examples with Phoenix

  Create the following files:

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

  use Openmaize.Confirm.Base

  def unpack_params(%{"password_reset" =>
      %{"email" => email, "key" => key, "password" => password}}) do
    {:email, email, key, password}
  end
end
