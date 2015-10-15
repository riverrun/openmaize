defmodule Openmaize.Token.Base do
  @moduledoc """
  """

  use Openmaize.Utils

  import Base
  alias Openmaize.Config

  def encode_token(payload, key \\ Config.secret_key) do
    data = (%{typ: "JWT", alg: "HS512"} |> from_map) <>
    "." <> (payload |> from_map)
    data <> "." <> (get_mac(key, data) |> urlenc64)
  end

  def decode_token(token, key \\ Config.secret_key) do
    :binary.split(token, ".", [:global]) |> check_all(key)
  end

  defp get_mac(key, data) do
    :crypto.hmac(:sha512, key, data)
  end

  defp from_map(input) do
    input |> Poison.encode! |> urlenc64
  end
  defp urlenc64(input) do
    input |> url_encode64 |> String.rstrip(?=)
  end

  defp to_map(input) do
    input |> urldec64 |> Poison.decode!(keys: :atoms!)
  end
  defp urldec64(data) do
    data <> case rem(byte_size(data), 4) do
      2 -> "=="
      3 -> "="
      _ -> ""
    end |> url_decode64!
  end

  defp check_all([enc_header, enc_payload, sign], key) do
    Enum.map([enc_header, enc_payload], &to_map/1)
    <|> check_header
    <|> check_sign(sign, key, enc_header, enc_payload)
    <|> check_exp
  end

  defp check_header([%{alg: alg, typ: "JWT"} = header, payload]) do
    case alg do
      "HS512" -> {:ok, payload}
      other -> {:error, "The #{other} algorithm is not supported."}
    end
  end
  defp check_header(_, _), do: {:error, "Invalid header."}

  defp check_sign({:ok, payload}, sign, key, enc_header, enc_payload) do
    if sign |> urldec64 == get_mac(key, enc_header <> "." <> enc_payload) do
      {:ok, payload}
    else
      {:error, "Invalid token."}
    end
  end

  defp check_exp({:ok, %{exp: exp} = payload}) do
    if exp > current_time, do: {:ok, payload}, else: {:error, "The token has expired."}
  end
  defp check_exp({:ok, payload}), do: {:ok, payload}

  def token_expiry_secs do
    current_time + Config.token_validity
  end

  defp current_time do
    {mega, secs, _} = :os.timestamp
    mega * 1000000 + secs
  end

end
