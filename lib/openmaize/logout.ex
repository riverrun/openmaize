defmodule Openmaize.Logout do
  @moduledoc """
  Plug to handle logout requests.

  After logging out, the user's token is added to a store of invalidated
  tokens, so it cannot be used again.

  If the token was stored in a cookie, then the cookie will be deleted.
  If the token was stored in sessionStorage, then you need to use the
  front-end framework to delete the token.

  ## Examples with Phoenix

  In the `web/router.ex` file, add the following line (you can use
  a different controller and route):

      get "/logout", PageController, :logout

  And then in the `page_controller.ex` file, add:

      plug Openmaize.Logout when action in [:logout]

  # add example `logout` function
  """

  import Plug.Conn
  alias Openmaize.JWTmanager

  @behaviour Plug

  def init(opts), do: opts

  @doc """
  Handle logout.
  """
  def call(%Plug.Conn{req_cookies: %{"access_token" => token}} = conn, _opts) do
    JWTmanager.add_jwt(token)
    assign(conn, :current_user, nil)
    |> delete_resp_cookie(conn, "access_token")
    |> put_private(:openmaize_info, %{"info" => "You have been logged out"})
  end
  def call(%Plug.Conn{req_headers: headers} = conn, _opts) do
    case List.keyfind(headers, "authorization", 0) do
      {_, "Bearer " <> token} -> JWTmanager.add_jwt(token)
      nil -> nil
    end
    assign(conn, :current_user, nil)
    |> put_private(:openmaize_info, %{"info" => "You have been logged out"})
  end
end
