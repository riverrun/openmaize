defmodule Openmaize.ConfirmEmail do
  @moduledoc """
  Confirm a user's email address.

  See the documentation for `add_confirm_token` and `add_reset_token` in
  the Openmaize.DB module for details about creating the token.

  ## Options

  There are three options:

    * key_expires_after - the length, in minutes, that the token is valid for
      * the default is 120 minutes (2 hours)
    * unique_id - the identifier in the query string, or the parameters
      * the default is :email
    * mail_function - the emailing function that you need to define

  ## Examples

  First, define a `get "/confirm"` route in the web/router.ex file.
  Then, add the following command to the relevant controller file:

      plug Openmaize.ConfirmEmail, [mail_function: &Mailer.send_receipt/1] when action in [:confirm]

  This command will be run when the user accesses the `confirm` route.
  """

  use Openmaize.Confirm.Base

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
    key = :crypto.strong_rand_bytes(24) |> Base.url_encode64()
    {key, "#{unique_id}=#{URI.encode_www_form(user_id)}&key=#{key}"}
  end
end
