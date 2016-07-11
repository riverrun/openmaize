defmodule Openmaize.AuthenticateTest do
  use ExUnit.Case
  use Plug.Test

  alias Openmaize.Authenticate

  setup_all do
  end

  def call(url) do
    conn(:get, url)
    |> fetch_session
    |> Authenticate.call()
  end

end
