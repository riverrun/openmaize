defmodule Openmaize.Logout do
  @moduledoc """
  Plug to handle logout requests.

  If the token was stored in a cookie, then the user will be redirected
  to the path set for "logout" in `redirect_pages` in the config. If
  the token was stored in sessionStorage, then there are no redirects
  on logout. You will also need to use the front end framework to delete
  the token.

  ## Examples with Phoenix

  In the `web/router.ex` file, add the following line (you can use
  a different controller and route):

      get "/logout", PageController, :logout

  And then in the `page_controller.ex` file, add:

      plug Openmaize.Logout when action in [:logout]

  """

  import Plug.Conn
  import Openmaize.Redirect
  alias Openmaize.Config

  @behaviour Plug

  def init(opts), do: opts

  @doc """
  Handle logout.

  If the token was stored in a cookie, the cookie will be deleted.
  If the token was not stored in a cookie, then you will need to use
  your front end framework to delete the token.
  """
  def call(%Plug.Conn{req_cookies: %{"access_token" => _token}} = conn, _opts) do
    assign(conn, :current_user, nil) |> logout_user()
  end
  def call(conn, _opts), do: assign(conn, :current_user, nil) |> halt

  def logout_user(conn) do
    delete_resp_cookie(conn, "access_token")
    |> redirect_to("#{Config.redirect_pages["logout"]}", %{"info" => "You have been logged out"})
  end
end
