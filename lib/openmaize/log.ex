defmodule Openmaize.Log do
  @moduledoc """
  Logging functions for Openmaize.

  ## Format

  Openmaize uses logfmt to provide a standard logging format.

    15:31:08.575 [warn] path=/session/create user=ray@mail.com message=invalid password

    * path - the request path
    * user - the user identifier (one of email, username, nil)
    * message - error / info message
    * meta - additional metadata that does not fit into any of the other categories
  """

  defstruct user: "nil", message: "", meta: []

  @doc """
  Transforms an Openmaize log entry into standard logfmt

  ## Examples

      iex> conn = %Plug.Conn{request_path: "/"}
      ...> log_entry = %Openmaize.Log{user: "johnny", message: "logged", meta: [{"query", "something"}]}
      ...> Openmaize.Log.logfmt(conn.request_path, log_entry)
      "path=/ user=johnny message=logged query=something"

  """
  def logfmt(path, %Openmaize.Log{user: user, message: message, meta: meta}) do
    ([{"path", path}, {"user", user}, {"message", message}] ++ meta)
    |> Enum.map_join(" ", &format/1)
  end

  @doc """
  Returns the id of the currently logged-in user, if present.
  """
  def current_user_id(%{current_user: %{id: id}}), do: "#{id}"
  def current_user_id(_), do: "nil"

  defp format({key, val}) do
    if String.contains?(val, [" ", "="]) do
      ~s(#{key}="#{val}")
    else
      ~s(#{key}=#{val})
    end
  end
end
