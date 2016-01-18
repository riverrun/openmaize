defmodule Openmaize.Confirm do
  @moduledoc """
  """

  import Ecto.{Query, Changeset}
  import Comeonin.Tools
  alias Openmaize.Config

  @doc """
  """
  def confirm_user(%Plug.Conn{params: %{email: email, key: key}} = _conn, _opts) do
    email |> URI.decode_www_form |> check_user(key)
  end

  @doc """
  """
  def gen_token_link(email) do
    key = :crypto.strong_rand_bytes(24) |> Base.url_encode64
    {key, "email=#{URI.encode_www_form(email)}&key=#{key}"}
  end

  defp check_user(email, key) do
    from(u in Config.user_model,
         where: u.email == ^email,
         select: u)
    |> Config.repo.one
    |> check_key(key)
  end

  defp check_key(user, key) do
    secure_check(user.confirmation_token, key) and
    change(user, %{confirmed: true}) |> Config.repo.update!
  end

end
