defmodule Openmaize.Logout do
  @moduledoc """
  Plug to handle logout requests.

  After logging out, the user's token is added to a store of invalidated
  tokens, so it cannot be used again.

  If the token was stored in a cookie, then the user will be redirected
  to the path set for "logout" in `redirect_pages` in the config. If
  the token was stored in sessionStorage, then there are no redirects
  on logout. If you want to delete the token, you need to use the
  front-end framework to do so.

  ## Examples with Phoenix

  In the `web/router.ex` file, add the following line (you can use
  a different controller and route):

      get "/logout", PageController, :logout

  And then in the `page_controller.ex` file, add:

      plug Openmaize.Logout when action in [:logout]

  In the example above, there is no need to write a function for `logout`
  in your controller file.
  """

  import Plug.Conn
  import Openmaize.Redirect
  alias Openmaize.Config
  alias Openmaize.JWTmanager

  @behaviour Plug

  def init(opts), do: opts

  @doc """
  Handle logout.
  """
  def call(%Plug.Conn{req_cookies: %{"access_token" => token}} = conn, _opts) do
    JWTmanager.add_jwt(token)
    assign(conn, :current_user, nil) |> logout_user()
  end
  def call(%Plug.Conn{req_headers: headers} = conn, _opts) do
    case List.keyfind(headers, "authorization", 0) do
      {_, "Bearer " <> token} -> JWTmanager.add_jwt(token)
      nil -> nil
    end
    assign(conn, :current_user, nil) |> halt
  end

  def logout_user(conn) do
    delete_resp_cookie(conn, "access_token")
    |> redirect_to("#{Config.redirect_pages["logout"]}", %{"info" => "You have been logged out"})
  end
end
