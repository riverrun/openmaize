defmodule Openmaize.Token.Create do
  @moduledoc """
  """

  import Base
  import Openmaize.Token.Tools
  alias Openmaize.Config

  @header_alg Config.get_token_alg |> elem(0)
  @encode_alg Config.get_token_alg |> elem(1)

  @doc """
  Generate token.
  """
  def generate_token(user, {nbf_delay, token_validity}) do
    Map.take(user)
    |> Map.merge(%{nbf: current_time + nbf_delay, exp: current_time + token_validity})
    |> encode
  end

  defp encode(payload) do
    data = (%{typ: "JWT", alg: @header_alg, kid: current_kid} |> from_map) <>
    "." <> (payload |> from_map)
    {:ok, data <> "." <> (get_mac(data, @encode_alg, current_kid) |> urlenc64)}
  end

  defp from_map(input) do
    input |> Poison.encode! |> urlenc64
  end
  defp urlenc64(input) do
    input |> url_encode64 |> String.rstrip(?=)
  end

end
