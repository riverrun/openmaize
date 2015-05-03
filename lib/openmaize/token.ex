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

  def encode(claims) do
    Joken.encode(claims)
  end

  def decode(token) do
    Joken.decode(token)
  end
end
