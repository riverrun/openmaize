defmodule Openmaize.LoginTest do
  use ExUnit.Case
  use Plug.Test

  alias Openmaize.Login

  def call(name, password, uniq, opts) do
    conn(:post, "/login",
         %{"user" => %{uniq => name, "password" => password}})
    |> Login.call(opts)
  end

  def custom_query(user_id, :name) do
    %{name: user_id, role: "user", password_hash: Comeonin.Bcrypt.hashpwsalt("hard2guess")}
  end
  def custom_query(user_id, :email) do
    %{email: user_id, role: "user", password_hash: Comeonin.Bcrypt.hashpwsalt("hard2guess")}
  end

  test "get user params with name" do
    opts = {true, :cookie, {0, 1440}, :name, &custom_query/2}
    conn = call("fred", "hard2guess", "name", opts)
    assert conn.params["user"] == %{"name" => "fred", "password" => "hard2guess"}
    assert conn.status == 302
  end

  test "get user params with email" do
    opts = {true, :cookie, {0, 1440}, :email, &custom_query/2}
    conn = call("fred@mail.com", "hard2guess", "email", opts)
    assert conn.params["user"] == %{"email" => "fred@mail.com", "password" => "hard2guess"}
    assert conn.status == 302
  end

end
