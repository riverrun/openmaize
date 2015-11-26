defmodule Openmaize.Token.Verify do
  @moduledoc """
  Module to verify JSON Web Tokens.
  """

  use ErrorPipe
  import Base
  import Openmaize.Token.Tools

  @doc """
  Decode JWT.
  """
  def decode(token) do
    :binary.split(token, ".", [:global]) |> verify_token
  end

  @doc """
  Verify that the JWT is valid.
  """
  def verify_token([enc_header, enc_payload, sign]) do
    error_pipe(
      Enum.map([enc_header, enc_payload], &to_map/1)
      |> check_header
      |> check_sign(sign, enc_header, enc_payload)
      |> check_nbf
      |> check_exp)
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

  defp check_header([%{alg: alg, typ: "JWT", kid: kid}, payload]) do
    case alg do
      "HS512" -> {:ok, payload, :sha512, kid}
      "HS256" -> {:ok, payload, :sha256, kid}
      other -> {:error, "The #{other} algorithm is not supported."}
    end
  end
  defp check_header(_), do: {:error, "Invalid header."}

  defp check_sign({:ok, payload, alg, kid}, sign, enc_header, enc_payload) do
    if sign |> urldec64 == get_mac(enc_header <> "." <> enc_payload, alg, kid) do
      {:ok, payload}
    else
      {:error, "Invalid token."}
    end
  end

  defp check_nbf({:ok, %{nbf: nbf} = payload}) do
    nbf < current_time && {:ok, Map.delete(payload, :nbf)} || {:error, "The token cannot be used yet."}
  end
  defp check_nbf({:ok, _payload}), do: {:error, "There is no nbf value in the token."}

  defp check_exp({:ok, %{exp: exp} = payload}) do
    exp > current_time && {:ok, Map.delete(payload, :exp)} || {:error, "The token has expired."}
  end
  defp check_exp({:ok, _payload}), do: {:error, "There is no exp value in the token."}

end
