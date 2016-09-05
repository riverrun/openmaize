defmodule <%= base %>.Mailer do
  @moduledoc """
  A dummy module for sending emails.
  """

  @doc """
  An email with a confirmation link in it.
  """
  def ask_confirm(_email, link) do
    confirm_url = "http://www.example.com/sessions/confirm_email?#{link}"
    IO.puts confirm_url
  end

  @doc """
  An email with a link to reset the password.
  """
  def ask_reset(_email, link) do
    confirm_url = "http://www.example.com/password_resets/edit?#{link}"
    IO.puts confirm_url
  end

  @doc """
  An email acknowledging that the account has been successfully confirmed.
  """
  def receipt_confirm(email) do
    IO.inspect email
  end
end
