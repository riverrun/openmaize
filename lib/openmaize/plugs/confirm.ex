defmodule Openmaize.Confirm do
  @moduledoc """
  Module to help with email confirmation.

  This module can be used for account confirmation by email or for
  resetting a password.

  See the documentation for `add_confirm_token` and `add_reset_token` in
  the Openmaize.Signup module for details about creating the token.
  """

  use Openmaize.Pipe

  import Comeonin.Tools
  import Ecto.Changeset
  import Openmaize.Report
  alias Openmaize.{Config, QueryTools, Signup}

  @doc """
  Function to confirm a user's email address.

  ## Options

  There are five options:

  * key_expires_after - the length, in minutes, that the token is valid for
    * the default is 1440 minutes, or one day
  * unique_id - the identifier in the query string, or the parameters
    * the default is :email
  * mail_function - the emailing function that you need to define
  * redirects - if Openmaize should handle the redirects or not
    * the default true
  * query_function - the function to query the database
    * if you are using Ecto, you will probably not need this

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
  def confirm_email(conn, opts), do: invalid_link_error(conn, opts)

  @doc """
  Function to authenticate a user when resetting the password.

  See the documentation for `confirm_email` for details about the available
  options.

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
  def reset_password(conn, opts), do: invalid_link_error(conn, opts)

  defp get_opts(opts) do
    {Keyword.get(opts, :key_expires_after, 1440),
     Keyword.get(opts, :unique_id, :email),
     Keyword.get(opts, :mail_function),
     Keyword.get(opts, :redirects, true),
     Keyword.get(opts, :query_function, &QueryTools.find_user/2)}
  end

  defp check_user_key(conn, user_params, key, password,
                      {key_expiry, uniq, mail_func, redirects, query_func}) do
    user_id = Map.get(user_params, to_string(uniq))
    error_pipe(user_id
               |> URI.decode_www_form
               |> query_func.(uniq)
               |> check_key(key, key_expiry * 60, password))
    |> finalize(conn, user_id, mail_func, redirects)
  end

  defp check_key(nil, _, _, _), do: false
  defp check_key(user, key, valid_secs, :nopassword) do
    check_time(user.confirmation_sent_at, valid_secs) and
    secure_check(user.confirmation_token, key) and
    change(user, %{confirmed_at: Ecto.DateTime.utc}) |> Config.repo.update
  end
  defp check_key(user, key, valid_secs, password) do
    check_time(user.reset_sent_at, valid_secs) and
    secure_check(user.reset_token, key) and
    Signup.reset_password(user, password)
  end

  defp check_time(nil, _), do: false
  defp check_time(sent_at, valid_secs) do
    (sent_at |> Ecto.DateTime.to_erl
     |> :calendar.datetime_to_gregorian_seconds) + valid_secs >
    (:calendar.universal_time |> :calendar.datetime_to_gregorian_seconds)
  end

  defp finalize({:ok, user}, conn, _, mail_func, redirects) do
    mail_func && mail_func.(user.email)
    put_message(conn, %{"info" => "Account successfully confirmed"}, redirects)
  end
  defp finalize(false, conn, user_id, _, redirects) do
    put_message(conn, "logout", %{"error" => "Confirmation for #{user_id} failed"}, redirects)
  end
  defp finalize(nil, conn, _, _, redirects) do
    put_message(conn, "logout", %{"error" => "Confirmation failed"}, redirects)
  end

  defp invalid_link_error(conn, opts) do
    redirects = Keyword.get(opts, :redirects, true)
    put_message(conn, "logout", %{"error" => "Invalid link"}, redirects)
  end
end
