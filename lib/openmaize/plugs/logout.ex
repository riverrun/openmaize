defmodule Openmaize.Logout do
  @moduledoc """
  Plug to handle logout requests.

  There is one option:

  * redirects - if true, which is the default, redirect on login

  If the token was stored in sessionStorage, then redirects is automatically
  set to false. You will also need to use the front end framework to delete
  the token.

  ## Examples with Phoenix

  In the `web/router.ex` file, add the following line (you can use
  a different controller and route):

      get "/logout", PageController, :logout

  And then in the `page_controller.ex` file, add:

      use Openmaize.Logout

      plug logout when action in [:logout]

  If you stored the token in a cookie, but you want redirects set to false:

      plug logout, [redirects: false] when action in [:logout]

  ## Overriding these functions

  """

  defmacro __using__(_) do
    quote do

      import Plug.Conn
      import Openmaize.Report

      @doc """
      Handle logout.

      If the token was stored in a cookie, the cookie will be deleted.
      If the token was not stored in a cookie, then you will need to use
      your front end framework to delete the token.
      """
      def logout(%Plug.Conn{req_cookies: %{"access_token" => _token}} = conn, opts) do
        redirects = Keyword.get(opts, :redirects, true)
        assign(conn, :current_user, nil) |> logout_user(redirects)
      end
      def logout(conn, _opts), do: assign(conn, :current_user, nil) |> halt

      def logout_user(conn, true) do
        delete_resp_cookie(conn, "access_token")
        |> handle_info("You have been logged out")
      end
      def logout_user(conn, false), do: delete_resp_cookie(conn, "access_token") |> halt

      defoverridable [logout: 2, logout_user: 2]
    end
  end
end
