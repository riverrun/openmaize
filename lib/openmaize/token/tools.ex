defmodule Openmaize.Token.Tools do
  @moduledoc """
  """

  alias Openmaize.Config

  def get_mac(data, alg, kid) do
    :crypto.hmac(alg, get_key(kid), data)
  end

  def get_key(_kid) do
    "My hovercraft is full of eels!"
  end

  def current_kid do
    "1"
  end

  def current_time do
    {mega, secs, _} = :os.timestamp
    mega * 1000000 + secs
  end
end
