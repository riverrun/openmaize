defmodule Openmaize.TokenConfig do
  @behaviour Joken.Config

  def secret_key() do
    Openmaize.Config.secret_key
  end

  def algorithm() do
    :HS512
  end

  def encode(map) do
    Poison.encode!(map)
  end

  def decode(binary) do
    Poison.decode!(binary, keys: :atoms!)
  end

  def claim(:exp, payload) do
    Joken.Config.get_current_time() + 300
  end

  def claim(_, _) do
    nil
  end

  def validate_claim(:exp, payload) do
    Joken.Config.validate_time_claim(payload, :exp, "Token expired",
    fn(expires_at, now) -> expires_at > now end)
  end

  def validate_claim(_, _) do
    :ok
  end
end
