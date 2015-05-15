defmodule Openmaize.LoginTest do
  use ExUnit.Case

  alias Openmaize.Signup
  alias Openmaize.Login
  alias Openmaize.Token

  defmodule User do
    defstruct name: "John", password_hash: Signup.create_password_hash("password")
  end

  defmodule UserRole do
    defstruct name: "Fred", role: "admin", password_hash: Signup.create_password_hash("defaultpassword")
  end

  test "check valid password hashes" do
    assert Login.check_user(%User{}, "password") == %User{}
    assert Login.check_user(%UserRole{}, "defaultpassword") == %UserRole{}
  end

  test "check invalid password hashes" do
    users = [
      %User{name: "Fred", password_hash: Signup.create_password_hash("pasw0rd")},
      %User{name: "Tom", password_hash: Signup.create_password_hash("pa$sword")},
      %UserRole{name: "Dick", role: "admin", password_hash: Signup.create_password_hash("passw0rd")},
      %UserRole{name: "Harry", role: "admin", password_hash: Signup.create_password_hash("p@sw0rd")},
      nil
    ]
    for user <- users do
      refute Login.check_user(user, "password")
    end
  end

  test "generated token" do
    {:ok, token} = Login.generate_token(%User{})
    {:ok, data} = Token.decode(token)
    assert Map.get(data, :name) == "John"
    refute Map.get(data, :name) == "Fred"
    assert Map.has_key?(data, :exp)
  end

  test "generated token with role" do
    {:ok, token} = Login.generate_token(%UserRole{})
    {:ok, data} = Token.decode(token)
    assert Map.get(data, :name) == "Fred"
    refute Map.get(data, :name) == "John"
    assert Map.get(data, :role) == "admin"
    refute Map.get(data, :role) == "user"
    assert Map.has_key?(data, :exp)
  end
end
