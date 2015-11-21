defmodule Openmaize.Token.Create do
  @moduledoc """
  """

  import Base
  import Openmaize.Token.Tools
  alias Openmaize.Config

  @doc """
  Generate token.
  """
  def generate_token(user, {nbf_delay, token_validity}) do
    nbf = get_nbf(nbf_delay * 1000)
    Map.take(user, [:id, :name, :role])
    |> Map.merge(%{nbf: nbf, exp: get_expiry(nbf, token_validity * 1000)})
    |> encode(Config.get_token_alg)
  end

  defp get_nbf(nbf_delay) when is_integer(nbf_delay) do
    current_time + nbf_delay
  end
  defp get_nbf(_), do: raise ArgumentError, message: "nbf should be an integer."

  defp get_expiry(nbf, token_validity) when is_integer(token_validity) do
    nbf + token_validity
  end
  defp get_expiry(_, _), do: raise ArgumentError, message: "exp should be an integer."

  defp encode(payload, {header_alg, encode_alg}) do
    data = (%{typ: "JWT", alg: header_alg, kid: current_kid} |> from_map) <>
    "." <> (payload |> from_map)
    {:ok, data <> "." <> (get_mac(data, encode_alg, current_kid) |> urlenc64)}
  end

  defp from_map(input) do
    input |> Poison.encode! |> urlenc64
  end
  defp urlenc64(input) do
    input |> url_encode64 |> String.rstrip(?=)
  end

end
