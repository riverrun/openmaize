defmodule Openmaize.JSON do
  alias Poison, as: JSON
  @behaviour Joken.Codec

  @doc """
  Encode function for use with Joken.
  """
  def encode(map), do: JSON.encode!(map)

  @doc """
  Decode function for use with Joken.
  """
  def decode(binary), do: JSON.decode!(binary, keys: :atoms!)

end
