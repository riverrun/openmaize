defmodule Openmaize.Confirm do
  @moduledoc """
  Module to help with email confirmation.

  This module can be used for account confirmation by email or for
  resetting a password.

  See the documentation for `add_confirm_token` and `add_reset_token` in
  the Openmaize.DB module for details about creating the token.
  """

  import Plug.Conn
  import Comeonin.Tools
  import Openmaize.{Pipe, Redirect}
  alias Openmaize.Config

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

  @doc """
  Function to confirm a user's email address.

  ## Options

  There are four options:

  * key_expires_after - the length, in minutes, that the token is valid for
    * the default is 120 minutes (2 hours)
  * unique_id - the identifier in the query string, or the parameters
    * the default is :email
  * mail_function - the emailing function that you need to define
  * redirects - if Openmaize will handle redirects or not
    * this should be a map containing a `success` key with path and a `failure`
    key with path, for example, %{success: "/login", failure: "/"}, or false
    * the default is %{success: "/login", failure: "/"}

  ## Examples

  First, define a `get "/confirm"` route in the web/router.ex file.
  Then, in the controller file, `import Openmaize.Confirm` and run the
  following command:

      plug :confirm_email, [mail_function: &Mailer.send_receipt/1] when action in [:confirm]

  This command will be run when the user accesses the `confirm` route.
  There is no need to write a confirm function in your controller.
  """
  def confirm_email(%Plug.Conn{params: %{"key" => key} = user_params} = conn, opts)
  when byte_size(key) == 32 do
    check_user_key(conn, user_params, key, :nopassword, get_opts(opts))
  end
  def confirm_email(conn, opts) do
    invalid_link_error(conn, Keyword.get(opts, :redirects, %{success: "/login", failure: "/"}))
  end

  @doc """
  Function to authenticate a user when resetting the password.

  See the documentation for `confirm_email` for details about the available
  options.

  ## Reset password form

  This function is to be used with the `reset` post request. For the
  `reset` get request, you need to render a form with the name "user",
  using `[as: :user]` if you are using Phoenix's `form_for` function,
  which contains values for the password, email and key (the email and
  key should be hidden inputs).

  Any password validation needs to be done on the front-end.

  ## Examples

  First, define a `post "/reset", SomeController, :reset_password` route
  in the web/router.ex file. Then, in the controller file, `import Openmaize.Confirm`
  and run the following command:

      plug :reset_password, [mail_function: &Mailer.send_receipt/1] when action in [:reset_password]

  This command will be run when the user sends the form with the data to
  reset the password. There is no need to write a reset_password function
  in your controller, but you will need to write a function to handle the
  `get "/reset"` request, that is, to render the form to reset the password.
  """
  def reset_password(%Plug.Conn{params: %{"user" =>
                    %{"key" => key, "password" => password} = user_params}} = conn, opts)
  when byte_size(key) == 32 do
    check_user_key(conn, user_params, key, password, get_opts(opts))
  end
  def reset_password(conn, opts) do
    invalid_link_error(conn, Keyword.get(opts, :redirects, %{success: "/login", failure: "/"}))
  end

  defp get_opts(opts) do
    {Keyword.get(opts, :key_expires_after, 120),
     Keyword.get(opts, :unique_id, :email),
     Keyword.get(opts, :mail_function),
     Keyword.get(opts, :redirects, %{success: "/login", failure: "/"})}
  end

  defp check_user_key(conn, user_params, key, password,
                      {key_expiry, uniq, mail_func, redirects}) do
    user_id = Map.get(user_params, to_string(uniq))
    error_pipe(user_id
               |> URI.decode_www_form
               |> Config.db_module.find_user(uniq)
               |> check_key(key, key_expiry * 60, password))
    |> finalize(conn, user_id, mail_func, redirects)
  end

  defp check_key(nil, _, _, _), do: false
  defp check_key(user, key, valid_secs, :nopassword) do
    Config.db_module.check_time(user.confirmation_sent_at, valid_secs) and
    secure_check(user.confirmation_token, key) and
    Config.db_module.user_confirmed(user)
  end
  defp check_key(user, key, valid_secs, password) do
    Config.db_module.check_time(user.reset_sent_at, valid_secs) and
    secure_check(user.reset_token, key) and
    Config.db_module.password_reset(user, password)
  end

  defp finalize({:ok, user}, conn, _, mail_func, false) do
    mail_func && mail_func.(user.email)
    send_resp(conn, 200, Poison.encode!(%{"info" => "Account successfully confirmed"})) |> halt()
  end
  defp finalize({:ok, user}, conn, _, mail_func, %{success: success_path}) do
    mail_func && mail_func.(user.email)
    redirect_to(conn, success_path, %{"info" => "Account successfully confirmed"})
  end
  defp finalize(_, conn, user_id, _, false) do
    send_resp(conn, 401, Poison.encode!(%{"error" => "Confirmation for #{user_id} failed"}))
    |> halt()
  end
  defp finalize(_, conn, user_id, _, %{failure: fail_path}) do
    redirect_to(conn, fail_path, %{"error" => "Confirmation for #{user_id} failed"})
  end

  defp invalid_link_error(conn, %{failure: fail_path}) do
    redirect_to(conn, fail_path, %{"error" => "Invalid link"})
  end
  defp invalid_link_error(conn, _) do
    send_resp(conn, 401, %{"error" => "Invalid link"}) |> halt()
  end
end
