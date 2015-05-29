defmodule Openmaize.JSON do
  alias Poison, as: JSON
  @behaviour Joken.Codec

  @doc """
  Encode function for use with Joken.
  """
  def encode(map) do
    JSON.encode!(map)
  end

  @doc """
  Decode function for use with Joken.
  """
  def decode(binary) do
    JSON.decode!(binary, keys: :atoms!)
  end
end
defmodule Openmaize.Token do
  @moduledoc """
  Module to encode and decode JWTs.
  """

  @secret_key Openmaize.Config.secret_key
  @json_module Openmaize.JSON
  @algorithm :HS512

  @doc """
  Encode JWT.
  """
  def encode(payload, claims \\ %{}) do
    Joken.Token.encode(@secret_key, @json_module, payload, @algorithm, claims)
  end

  @doc """
  Decode JWT.
  """
  def decode(token, claims \\ %{}) do
    Joken.Token.decode(@secret_key, @json_module, token, @algorithm, claims)
  end
end
