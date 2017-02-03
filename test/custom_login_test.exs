defmodule Openmaize.CustomLoginTest do
  use ExUnit.Case
  use Plug.Test

  alias Openmaize.{CustomLogin, CustomLogin.Phonename, TestRepo, TestUser}

  defp login(module, name, password, uniq, opts) do
    conn(:post, "/login",
         %{"session" => %{uniq => name, "password" => password}})
    |> module.call(opts)
  end

  test "login succeeds with custom name" do
    opts = {TestRepo, TestUser}
    conn = login(CustomLogin, "081555555", "h4rd2gU3$$", "phone", opts)
    %{id: id, role: role} = conn.private[:openmaize_user]
    assert id == 4
    assert role == "user"
  end

  test "login fails for incorrect password" do
    opts = {TestRepo, TestUser}
    conn = login(CustomLogin, "081555555", "oohwhatwasitagain", "phone", opts)
    assert conn.private[:openmaize_error]
  end

  test "login succeeds with custom function - phone or username" do
    opts = {TestRepo, TestUser}
    conn = login(Phonename, "081555555", "h4rd2gU3$$", "phone", opts)
    %{id: id} = conn.private[:openmaize_user]
    assert id == 4
    conn = login(Phonename, "ray", "h4rd2gU3$$", "phone", opts)
    %{id: id} = conn.private[:openmaize_user]
    assert id == 4
  end

end
