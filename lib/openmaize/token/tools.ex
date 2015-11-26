defmodule Openmaize.Token.Tools do
  @moduledoc """
  Various tools that are used with the management of JSON Web Tokens.
  """

  alias Openmaize.Keymanager

  @doc """
  The hash to be used when checking the signature.
  """
  def get_mac(data, alg, kid) do
    :crypto.hmac(alg, get_key(kid), data)
  end

  @doc """
  The secret key to be used to check the signature.
  """
  def get_key(kid) do
    Keymanager.get_key(kid)
  end

  @doc """
  The current value for `kid` in the JWT header.
  """
  def current_kid do
    Keymanager.get_current_kid
  end

  @doc """
  The current time in milliseconds.
  """
  def current_time do
    {mega, secs, micro} = :os.timestamp
    trunc(((mega * 1000000 + secs) * 1000) + (micro / 1000))
  end
end
