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
      Log.logfmt(conn, %Log{
                   user: "arrr@mail.com",
                   message: "account confirmed",
                   meta: [{"current_user_id", Log.current_user_id(conn)}]})
      |> Logger.warn
    end) =~ ~s(path=/confirm user=arrr@mail.com message="account confirmed" current_user_id=1)
  end

  test "logs to console in standard logfmt for nil current_user" do
    assert capture_log(fn ->
      conn = conn(:get, "/login") |> assign(:current_user, nil)
      Log.logfmt(conn, %Log{
                   user: "arrr@mail.com",
                   message: "failed login"})
      |> Logger.warn
    end) =~ ~s(path=/login user=arrr@mail.com message="failed login")
  end

  test "quotes values containing '='" do
    assert capture_log(fn ->
      conn = conn(:get, "/confirm")
      Log.logfmt(conn, %Log{
                   message: "invalid query string",
                   meta: [{"query", "email=wrong%40mail.com"}]})
      |> Logger.warn
    end) =~ ~s(path=/confirm user=nil message="invalid query string" query="email=wrong%40mail.com")
  end

end
