defmodule Openmaize.JWT.Create do
  @moduledoc """
  Module to create JSON Web Tokens.

  ## Default token

  The header contains values for `typ`, which is "JWT", `alg`, which can be
  "HS256" or "HS512" (the default), and `kid`, which is used to identify
  which key was used in the signature.

  The main body of the token has user information and values for `nbf`, which
  is the time before which the token cannot be used, and `exp`, which is the
  time when the token expires.
  """

  import Base
  import Openmaize.JWT.Tools
  alias Openmaize.Config

  @doc """
  Generate a JSON Web Token.

  This function is usually called by the `add_token` function in the
  Openmaize.JWT module, but it can also be called directly.

  `user` is a map containing the user information, which needs to contain
  values for `id`, a unique identifier, which is `username` by default, `role`,
  `nbf_delay`, which is the number of minutes in the future after which
  the token can be used, and `token_validity`, which is the number of
  minutes that the token will be valid for.
  """
  def generate_token(user, {nbf_delay, token_validity}) do
    nbf = get_nbf(nbf_delay * 60_000)
    #%{:nbf => nbf, :exp => get_expiry(nbf, token_validity * 60_000)}
    Map.merge(user, %{nbf: nbf, exp: get_expiry(nbf, token_validity * 60_000)})
    |> encode(Config.get_token_alg)
  end

  defp get_nbf(nbf_delay) when is_integer(nbf_delay) do
    current_time + nbf_delay - 10_000
  end
  defp get_nbf(_), do: raise ArgumentError, "nbf should be an integer."

  defp get_expiry(nbf, token_validity) when is_integer(token_validity) do
    nbf + token_validity
  end
  defp get_expiry(_, _), do: raise ArgumentError, "exp should be an integer."

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
