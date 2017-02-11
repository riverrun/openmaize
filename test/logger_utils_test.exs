defmodule Openmaize.LoggerUtilsTest do
  use ExUnit.Case
  use Plug.Test
  import ExUnit.CaptureLog
  doctest Openmaize.LoggerUtils

  require Logger
  alias Openmaize.{LoggerUtils, LogEntry}

  @user %{id: 1, email: "arrr@mail.com", username: "FSM"}

  test "logs to console in standard logfmt" do
    assert capture_log(fn ->
      conn = conn(:get, "/confirm") |> assign(:current_user, @user)
      current_user_id = conn |> LoggerUtils.current_user_id
      log_entry = %LogEntry{
        user: "arrr@mail.com",
        message: "account confirmed",
        meta: [{"current_user_id", current_user_id}]}
      conn |> LoggerUtils.logfmt(log_entry) |> Logger.warn
    end) =~ "path=/confirm user=arrr@mail.com message=account confirmed current_user_id=1"
  end

  test "logs to console in standard logfmt for nil current_user" do
    assert capture_log(fn ->
      conn = conn(:get, "/login") |> assign(:current_user, nil)
      log_entry = %LogEntry{
        user: "arrr@mail.com",
        message: "failed login"}
      conn |> LoggerUtils.logfmt(log_entry) |> Logger.warn
    end) =~ "path=/login user=arrr@mail.com message=failed login"
  end
end
