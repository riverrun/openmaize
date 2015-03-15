defmodule Sanction.Config do
  @moduledoc """
  """

  def secret_key do
    Application.get_env(:sanction, :secret_key, "you will never guess")
  end
end
