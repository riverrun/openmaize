defmodule Openmaize.Logger do
  @moduledoc """
  Logger for Openmaize.

  ## Format

  This example shows the format that Openmaize uses in its log messages
  (the "-" shows a missing field):

    15:31:08.575 [warn] /session/create ray@mail.com - invalid password

  This message is split up into six parts (each part, up until the message,
  is separated by a space):

    timestamp logtype path user-identifier metadata message

    * timestamp
    * logtype - [warn] or [info]
    * path - the request path
    * user-identifier - the user's email or username
    * metadata - additional metadata that does not fit into any of the other categories
      * this has an identifier and the metadata separated by a colon
      * for example, "query:email=wrong%40mail.com" - for an invalid query string
    * message - error / info message

  """

  require Logger

  def info(conn, user_id, message, metadata \\ "-") do
    Logger.info "#{conn.request_path} #{user_id} #{metadata} #{message}"
  end

  def warn(conn, user_id, message, metadata \\ "-") do
    Logger.warn "#{conn.request_path} #{user_id} #{metadata} #{message}"
  end

  def current_user_info(%Plug.Conn{assigns: %{current_user: %{id: id}}}),
    do: "current_user:#{id}"
  def current_user_info(_), do: "-"
end
