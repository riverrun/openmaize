defmodule Openmaize.DummyCrypto do
  @moduledoc """
  A dummy crypto module for testing purposes
  """

  def hashpwsalt(password) do
    "dumb-#{password}-crypto"
  end

  def dummy_checkpw do
    false
  end

  def checkpw(password, salt) do
    salt == hashpwsalt(password)
  end
end
