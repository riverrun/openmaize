defmodule Openmaize.LoggerUtils do
  @moduledoc """
  Logger Utility functions for Openmaize.

  ## Format

  Openmaize uses logfmt to provide a standard logging format.

    15:31:08.575 [warn] path=/session/create user=ray@mail.com message=invalid password

    * path - the request path
    * user - the user identifier (one of email, username, nil)
    * message - error / info message
    * meta - additional metadata that does not fit into any of the other categories
  """

  alias Plug.Conn
  alias Openmaize.LogEntry

  @doc """
  Transforms an Openmaize log entry into standard logfmt

  ## Examples

      iex> conn = %Plug.Conn{request_path: "/"}
      ...> log_entry = %Openmaize.LogEntry{user: "johnny", message: "logged", meta: [{"query", "something"}]}
      ...> conn |> Openmaize.LoggerUtils.logfmt(log_entry)
      "path=/ user=johnny message=logged query=something"

  """
  @spec logfmt(%Plug.Conn{}, %LogEntry{}) :: String.t
  def logfmt(conn, %{user: user, message: message, meta: meta}) do
    %Conn{request_path: request_path} = conn
    standard_log = [{"path", request_path}, {"user", user}, {"message", message}]

    standard_log
    |> Enum.concat(meta)
    |> logfmt_string
    |> Enum.join(" ")
  end

  defp logfmt_string(entry) do
    for {k, v} <- entry do
      "#{k}=#{v}"
    end
  end

  @spec current_user_id(Conn.t) :: String.t
  def current_user_id(%Conn{assigns: %{current_user: %{id: id}}}), do: "#{id}"
  def current_user_id(_), do: "nil"
end
