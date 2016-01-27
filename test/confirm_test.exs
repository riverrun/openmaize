defmodule Openmaize.ConfirmTest do
  use ExUnit.Case
  use Plug.Test

  alias Openmaize.Confirm

  def call(name, password, uniq, opts) do
    conn(:get, "/confirm",
         %{"user" => %{uniq => name, "password" => password}})
    |> Confirm.user_email(opts)
  end


end
