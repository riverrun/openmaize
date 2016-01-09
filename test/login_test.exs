defmodule Openmaize.LoginTest do
  use ExUnit.Case
  use Plug.Test

  use Openmaize.Login

  def call(name, password, uniq, opts) do
    conn(:post, "/login",
         %{"user" => %{uniq => name, "password" => password}})
    |> login(opts)
  end

  def check_user(:name, "name", user_params), do: user_params
  def check_user(:email, "email", user_params), do: user_params

  def handle_auth(res, _, _), do: res

  test "get user params with name" do
    assert call("fred", "hard2guess", "name", []) ==
     %{"name" => "fred", "password" => "hard2guess"}
  end

  test "get user params with email" do
    assert call("fred@mail.com", "hard2guess", "email", [unique_id: :email]) ==
      %{"email" => "fred@mail.com", "password" => "hard2guess"}
  end

end
