defmodule Openmaize.AuthenticateTest do
  use ExUnit.Case
  use Plug.Test

  import Openmaize.Token.Create
  alias Openmaize.Authenticate

  setup_all do
    {:ok, user_token} = %{id: 1, name: "Raymond Luxury Yacht", role: "user"}
    |> generate_token(:name, {0, 86400})

    {:ok, exp_token} = %{id: 1, name: "Raymond Luxury Yacht", role: "user"}
    |> generate_token(:name, {0, 0})

    {:ok, nbf_token} = %{id: 1, name: "Raymond Luxury Yacht", role: "user"}
    |> generate_token(:name, {10, 10})

    Application.put_env(:openmaize, :token_alg, :sha256)
    {:ok, user_256_token} = %{id: 1, name: "Raymond Luxury Yacht", role: "user"}
    |> generate_token(:name, {0, 86400})
    Application.delete_env(:openmaize, :token_alg)

    {:ok, %{user_token: user_token, exp_token: exp_token,
            nbf_token: nbf_token, user_256_token: user_256_token}}
  end

  def call(url, token, :cookie) do
    conn(:get, url)
    |> put_req_cookie("access_token", token)
    |> fetch_cookies
    |> Authenticate.call([])
  end

  def call(url, token, _) do
    conn(:get, url)
    |> put_req_header("authorization", "Bearer #{token}")
    |> Authenticate.call([storage: nil])
  end

  test "expired token", %{exp_token: exp_token} do
    conn = call("/admin", exp_token, :cookie)
    assert conn.assigns ==  %{current_user: nil}
  end

  test "token that cannot be used yet", %{nbf_token: nbf_token} do
    conn = call("/admin", nbf_token, :cookie)
    assert conn.assigns ==  %{current_user: nil}
  end

  test "correct token stored in cookie", %{user_token: user_token} do
    conn = call("/", user_token, :cookie)
    assert conn.assigns == %{current_user: %{id: 1, name: "Raymond Luxury Yacht", role: "user"}}
  end

  test "invalid token stored in cookie", %{user_token: user_token} do
    conn = call("/users", user_token <> "a", :cookie)
    assert conn.assigns ==  %{current_user: nil}
  end

  test "correct token stored in sessionStorage", %{user_token: user_token} do
    conn = call("/", user_token, nil)
    assert conn.assigns ==  %{current_user: %{id: 1, name: "Raymond Luxury Yacht", role: "user"}}
  end

  test "invalid token stored in sessionStorage", %{user_token: user_token} do
    conn = call("/users", user_token <> "a", nil)
    assert conn.assigns ==  %{current_user: nil}
  end

  test "missing token" do
    conn = conn(:get, "/") |> Authenticate.call([])
    assert conn.assigns == %{current_user: nil}
  end

  test "correct token using sha256", %{user_256_token: user_256_token} do
    conn = call("/", user_256_token, :cookie)
    assert conn.assigns == %{current_user: %{id: 1, name: "Raymond Luxury Yacht", role: "user"}}
  end

  test "invalid token using sha256", %{user_256_token: user_256_token} do
    conn = call("/users", user_256_token <> "a", :cookie)
    assert conn.assigns ==  %{current_user: nil}
  end

end
