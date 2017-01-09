defmodule <%= base %>.Mailer do
  @moduledoc """
  A module for sending emails.

  These functions are used for email confirmation and password resetting.

  You need to complete these functions with the email library / module of
  your choice.
  """

  @doc """
  An email with a confirmation link in it.

  This function is called by the `create` function in the user_controller.
  It should send an email with the confirmation link to the user. The
  return value is not used.
  """
  def ask_confirm(_email, link) do
    confirm_url = "http://www.example.com/sessions/confirm_email?#{link}"
    confirm_url
  end

  @doc """
  An email with a link to reset the password.

  This function is called by the `create` function in the password_reset_controller.
  It should send an email with the link to reset the password to the user. The
  return value is not used.
  """
  def ask_reset(_email, link) do
    confirm_url = "http://www.example.com/password_resets/edit?#{link}"
    confirm_url
  end

  @doc """
  An email acknowledging that the account has been successfully confirmed.

  This function is called by the Openmaize.ConfirmEmail and the
  Openmaize.ResetPassword plugs. It should send an email stating that the
  account has been confirmed, or that the password has been reset, to the user.
  The return value is not used.
  """
  def receipt_confirm(email) do
    email
  end
end
