defmodule Openmaize.Logger do
  @moduledoc """
  Logger for Openmaize.
  """

  require Logger

  def info(conn, user_id, message, metadata \\ "-") do
    Logger.info "#{conn.request_path} #{current_user_info(conn)} #{user_id} #{metadata} #{message}"
  end

  def warn(conn, user_id, message, metadata \\ "-") do
    Logger.warn "#{conn.request_path} #{current_user_info(conn)} #{user_id} #{metadata} #{message}"
  end

  defp current_user_info(%Plug.Conn{assigns: %{current_user: user}}) do
    user[:email] || user[:username] || user[:id] || "-"
  end
  defp current_user_info(_), do: "-"
end
