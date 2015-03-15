defmodule Sanction.JWTCreate do
  @moduledoc """
  """

  alias Sanction.Config

  def generate_token(user) do
    Map.take(user, [:id])
    |> Map.merge(%{exp: token_expiry_secs})
    |> Joken.encode(Config.secret_key)
  end

  defp token_expiry_secs do
    (:calendar.universal_time
    |> :calendar.datetime_to_gregorian_seconds)
    + Config.token_validity
  end 
end
