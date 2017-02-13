defmodule Openmaize.LogTest do
  use ExUnit.Case
  use Plug.Test
  import ExUnit.CaptureLog
  doctest Openmaize.Log

  require Logger
  alias Openmaize.{Config, Log}

  @user %{id: 1, email: "arrr@mail.com"}

  test "logs to console" do
    assert capture_log(fn ->
      conn = conn(:get, "/confirm") |> assign(:current_user, @user)
      Log.log(:warn, Config.log_level, conn.request_path,
              %Log{user: "arrr@mail.com",
                message: "account confirmed",
                meta: [{"current_user_id", Log.current_user_id(conn.assigns)}]})
    end) =~ ~s(path=/confirm user=arrr@mail.com message="account confirmed" current_user_id=1)
  end

  test "logs to console for nil current_user" do
    assert capture_log(fn ->
      conn = conn(:get, "/login") |> assign(:current_user, nil)
      Log.log(:warn, Config.log_level, conn.request_path,
              %Log{user: "arrr@mail.com",
                message: "failed login"})
    end) =~ ~s(path=/login user=arrr@mail.com message="failed login")
  end

  test "quotes values containing '='" do
    assert capture_log(fn ->
      conn = conn(:get, "/confirm")
      Log.log(:warn, Config.log_level, conn.request_path,
              %Log{message: "invalid query string",
                meta: [{"query", "email=wrong%40mail.com"}]})
    end) =~ ~s(path=/confirm user=nil message="invalid query string" query="email=wrong%40mail.com")
  end

  test "does not print log if config log_level is false" do
    Application.put_env(:openmaize, :log_level, false)
    assert capture_log(fn ->
      conn = conn(:get, "/login")
      Log.log(:warn, Config.log_level, conn.request_path,
              %Log{user: "arrr@mail.com",
                message: "failed login"})
    end) =~ ""
  after
    Application.put_env(:openmaize, :log_level, :info)
  end

  test "does not print log if level is lower than config log_level" do
    Application.put_env(:openmaize, :log_level, :warn)
    assert capture_log(fn ->
      conn = conn(:get, "/login")
      Log.log(:info, Config.log_level, conn.request_path,
              %Log{user: "arrr@mail.com",
                message: "failed login"})
    end) =~ ""
  after
    Application.put_env(:openmaize, :log_level, :info)
  end

end
