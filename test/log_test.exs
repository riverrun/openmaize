defmodule Openmaize.LogTest do
  use ExUnit.Case
  use Plug.Test
  import ExUnit.CaptureLog
  doctest Openmaize.Log

  require Logger
  alias Openmaize.Log

  @user %{id: 1, email: "arrr@mail.com", username: "FSM"}

  test "logs to console in standard logfmt" do
    assert capture_log(fn ->
      conn = conn(:get, "/confirm") |> assign(:current_user, @user)
      Logger.warn fn ->
        Log.logfmt conn.request_path,
                   %Log{user: "arrr@mail.com",
                     message: "account confirmed",
                     meta: [{"current_user_id", Log.current_user_id(conn.assigns)}]}
      end
    end) =~ ~s(path=/confirm user=arrr@mail.com message="account confirmed" current_user_id=1)
  end

  test "logs to console in standard logfmt for nil current_user" do
    assert capture_log(fn ->
      conn = conn(:get, "/login") |> assign(:current_user, nil)
      Logger.warn fn ->
        Log.logfmt conn.request_path,
                   %Log{user: "arrr@mail.com",
                     message: "failed login"}
      end
    end) =~ ~s(path=/login user=arrr@mail.com message="failed login")
  end

  test "quotes values containing '='" do
    assert capture_log(fn ->
      conn = conn(:get, "/confirm")
      Logger.warn fn ->
        Log.logfmt conn.request_path,
                   %Log{message: "invalid query string",
                     meta: [{"query", "email=wrong%40mail.com"}]}
      end
    end) =~ ~s(path=/confirm user=nil message="invalid query string" query="email=wrong%40mail.com")
  end

end
