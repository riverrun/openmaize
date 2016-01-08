defmodule Openmaize.LoginTest do
  use ExUnit.Case
  use Plug.Test

  use Openmaize.Login

  def call(name, password, uniq, opts) do
    conn(:post, "/login",
         %{"user" => %{uniq => name, "password" => password}})
    |> login(opts)
  end

  def check_user(:name, user, password), do: {user, password}
  def check_user(:email, user, password), do: {user, password}

  test "get user params with name" do
    assert call("fred", "hard2guess", "name", []) == {"fred", "hard2guess"}
  end

  test "get user params with email" do
    Application.put_env(:openmaize, :unique_id, "email")
    assert call("fred@mail.com", "hard2guess", "email", []) == {"fred@mail.com", "hard2guess"}
    Application.put_env(:openmaize, :unique_id, "name")
  end

end
