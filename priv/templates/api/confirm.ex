defmodule <%= base %>.Confirm do
  import Plug.Conn
  import Phoenix.Controller
  import <%= base %>.Authorize

  @doc """
  Check the user's confirmation key.

  ## Examples

  Add the following line to the controller file:

      plug Openmaize.ConfirmEmail, [mail_function: &Mailer.receipt_confirm/1] when action in [:confirm]

  and then call `handle_confirm` from the `confirm` function in the controller.

  See the documentation for Openmaize.ConfirmEmail for more information.
  """
  def handle_confirm(%Plug.Conn{private: %{openmaize_error: message}} = conn, _params) do
    render(conn, <%= base %>.ErrorView, "error.json", %{error: message})
  end
  def handle_confirm(%Plug.Conn{private: %{openmaize_info: message}} = conn, _params) do
    render(conn, <%= base %>.UserView, "info.json", %{info: message})
  end

  @doc """
  Check the user's reset key.

  ## Examples

  Add the following line to the controller file:

      plug Openmaize.ResetPassword, [mail_function: &Mailer.receipt_confirm/1] when action in [:reset_password]

  and then call `handle_reset` from the `reset_password` function in the controller.

  See the documentation for Openmaize.ResetPassword for more information.
  """
  def handle_reset(%Plug.Conn{private: %{openmaize_error: message}} = conn, _params) do
    render(conn, <%= base %>.ErrorView, "error.json", %{error: message})
  end
  def handle_reset(%Plug.Conn{private: %{openmaize_info: message}} = conn, _params) do
    render(conn, <%= base %>.UserView, "info.json", %{info: message})
  end
end
