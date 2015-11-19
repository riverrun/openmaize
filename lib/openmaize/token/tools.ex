defmodule Openmaize.Token.Tools do
  @moduledoc """
  """

  alias Openmaize.Keymanager

  def get_mac(data, alg, kid) do
    :crypto.hmac(alg, get_key(kid), data)
  end

  def get_key(kid) do
    Keymanager.get_key(kid)
  end

  def current_kid do
    Keymanager.get_current_kid
  end

  def current_time do
    {mega, secs, micro} = :os.timestamp
    trunc(((mega * 1000000 + secs) * 1000) + (micro / 1000))
  end
end
