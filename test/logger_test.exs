defmodule Openmaize.LoggerTest do
  use ExUnit.Case
  use Plug.Test
  import ExUnit.CaptureLog

  alias Openmaize.Logger

  @user %{id: 1, email: "arrr@mail.com", username: "FSM"}

  test "logs standard format" do
    [_, logtype, path, user, metadata, message] = capture_log(fn ->
      conn = conn(:get, "/confirm") |> assign(:current_user, @user)
      Logger.info(conn, "arrr@mail.com", "account confirmed", Logger.current_user_info(conn))
    end) |> String.split(" ", trim: true, parts: 6)

    assert logtype =~ "[info]"
    assert path =~ "/confirm"
    assert user =~ "arrr@mail.com"
    assert metadata =~ "current_user:1"
    assert message =~ "account confirmed"
  end

  test "logs standard format for nil current_user" do
    [_, logtype, path, user, metadata, message] = capture_log(fn ->
      conn(:get, "/login")
      |> assign(:current_user, nil)
      |> Logger.warn("arrr@mail.com", "failed login")
    end) |> String.split(" ", trim: true, parts: 6)

    assert logtype =~ "[warn]"
    assert path =~ "/login"
    assert user =~ "arrr@mail.com"
    assert metadata =~ "-"
    assert message =~ "failed login"
  end

end
