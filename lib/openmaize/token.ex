defmodule Openmaize.JSON do
  alias Poison, as: JSON
  @behaviour Joken.Codec

  def encode(map) do
    JSON.encode!(map)
  end

  def decode(binary) do
    JSON.decode!(binary, keys: :atoms!)
  end
end
defmodule Openmaize.Token do
  @moduledoc """
  """

  @secret_key Openmaize.Config.secret_key
  @json_module Openmaize.JSON
  @algorithm :HS512

  def encode(payload, claims \\ %{}) do
    Joken.Token.encode(@secret_key, @json_module, payload, @algorithm, claims)
  end

  def decode(token, claims \\ %{}) do
    Joken.Token.decode(@secret_key, @json_module, token, @algorithm, claims)
  end
end
