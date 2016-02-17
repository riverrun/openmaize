defmodule Openmaize.Token.Verify do
  @moduledoc """
  Module to verify JSON Web Tokens.
  """

  use Openmaize.Pipe
  import Base
  import Openmaize.Token.Tools

  @doc """
  Decode the JWT and check that it is valid.

  As well as checking that the token is a valid JWT, this function also
  checks that it has a `kid` value in the header, `id`, `role`, `sub`, and
  valid `nbf` and `exp` values in the body, and that it uses a supported
  algorithm, either HMAC-sha512 or HMAC-sha256.
  """
  def verify_token(token) do
    :binary.split(token, ".", [:global]) |> check_valid
  end

  defp check_valid([enc_header, enc_payload, sign]) do
    error_pipe(Enum.map([enc_header, enc_payload], &to_map/1)
               |> check_header
               |> check_sign(sign, enc_header, enc_payload)
               |> check_payload)
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

  defp check_payload({:ok, %{id: _id, role: _role, sub: _sub, exp: exp, nbf: nbf} = payload}) do
    case nbf < current_time do
      true -> exp > current_time and {:ok, payload} || {:error, "The token has expired."}
      _ -> {:error, "The token cannot be used yet."}
    end
  end
  defp check_payload(_), do: {:error, "Incomplete token."}
end
