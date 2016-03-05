defmodule Openmaize.Confirm do
  @moduledoc """
  These functions have been deprecated.

  Please use `Openmaize.ConfirmEmail` or `Openmaize.ResetPassword` instead.
  """

  @doc false
  def confirm_email(_conn, _opts) do
    IO.write :stderr, "warning: calling 'plug :confirm_email' is deprecated, " <>
      "please use 'Openmaize.ConfirmEmail' instead.\n"
  end

  @doc false
  def reset_password(_conn, _opts) do
    IO.write :stderr, "warning: calling 'plug :reset_password' is deprecated, " <>
      "please use 'Openmaize.ResetPassword' instead.\n"
  end
end
