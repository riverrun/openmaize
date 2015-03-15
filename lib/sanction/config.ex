defmodule Sanction.Config do
  @moduledoc """
  """

  def secret_key do
    Application.get_env(:sanction, :secret_key, "you will never guess")
  end

  def token_validity do
    Application.get_env(:sanction, :token_validity_in_minutes, 24 * 60) * 60
  end
end
