defmodule Openmaize.LoggerTest do
  use ExUnit.Case
  use Plug.Test
  import ExUnit.CaptureLog

  alias Openmaize.Logger

  @user %{id: 1, email: "arrr@mail.com", username: "FSM"}

  test "logs standard format" do
    [_, logtype, path, current_user, user, metadata, message] = capture_log(fn ->
      conn(:get, "/confirm")
      |> assign(:current_user, @user)
      |> Logger.info("arrr@mail.com", "account confirmed")
    end) |> String.split(" ", trim: true, parts: 7)

    assert logtype =~ "[info]"
    assert path =~ "/confirm"
    assert current_user =~ "arrr@mail.com"
    assert user =~ "arrr@mail.com"
    assert metadata =~ "-"
    assert message =~ "account confirmed"
  end

  test "logs standard format for nil current_user" do
    [_, logtype, path, current_user, user, metadata, message] = capture_log(fn ->
      conn(:get, "/login")
      |> assign(:current_user, nil)
      |> Logger.warn("arrr@mail.com", "failed login")
    end) |> String.split(" ", trim: true, parts: 7)

    assert logtype =~ "[warn]"
    assert path =~ "/login"
    assert current_user =~ "-"
    assert user =~ "arrr@mail.com"
    assert metadata =~ "-"
    assert message =~ "failed login"
  end

end
