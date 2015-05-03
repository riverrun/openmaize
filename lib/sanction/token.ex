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

  alias Openmaize.Config

  @config %{secret_key: Config.secret_key, algorithm: :HS512, json_module: Openmaize.JSON}

  def encode(claims) do
    {:ok, joken} = Joken.start_link(@config)
    Joken.encode(joken, claims)
  end

  def decode(token) do
    {:ok, joken} = Joken.start_link(@config)
    Joken.decode(joken, token)
  end
end
