defmodule JWT do
  @moduledoc """
  """

  import Base

  def encode(payload \\ %{"name" => "Yacht", "id" => 1}, key \\ "the secret key") do
    data = (%{"typ" => "JWT", "alg" => "HS512"} |> from_map) <>
    "." <> (payload |> from_map)
    data <> "." <> (get_mac(key, data) |> url_encode64)
  end

  defp get_mac(key, data) do
    :crypto.hmac(:sha512, key, data)
  end

  def decode(token, key \\ "the secret key") do
    :binary.split(token, ".", [:global]) |> check_sign(key)
  end

  defp from_map(input) do
    input |> Poison.encode! |> url_encode64
  end

  defp to_map(input) do
    input |> url_decode64! |> Poison.decode!
  end

  defp check_sign([header, payload, sign], key) do
    [_header1, payload1] = Enum.map([header, payload], &to_map/1)
    if sign |> url_decode64! == get_mac(key, header <> "." <> payload) do
      payload1
    else
      "Nooooooo!"
    end
  end

end
