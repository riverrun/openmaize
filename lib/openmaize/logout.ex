defmodule Openmaize.Logout do
  @moduledoc """
  """

  import Plug.Conn
  alias Openmaize.Config

  @behaviour Plug

  def init(opts), do: opts

  def call(conn, opts \\ []) do
    logout_user(conn, opts, Config.storage_method)
  end

  def logout_user(conn, opts, storage) when storage == "cookie" do
    delete_resp_cookie(conn, "access_token", opts)
    |> Tools.redirect_page("/")
  end

  def logout_user(conn) do
    #remove from sessionStorage
    conn
  end

end
