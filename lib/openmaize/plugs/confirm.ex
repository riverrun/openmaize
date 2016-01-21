defmodule Openmaize.Confirm do
  @moduledoc """
  """

  import Ecto.{Query, Changeset}
  import Comeonin.Tools
  alias Openmaize.Config

  @doc """
  """
  def confirm_user(%Plug.Conn{params: %{email: email, key: key}} = _conn, opts) do
    func = Keyword.get(opts, :confirm_success)
    email |> URI.decode_www_form |> check_user(key) |> send_receipt(email, func)
  end

  defp check_user(email, key) do
    from(u in Config.user_model,
         where: u.email == ^email,
         select: u)
    |> Config.repo.one
    |> check_key(key)
  end

  defp check_key(user, key) do
    secure_check(user.confirmation_token, key) and user
  end

  defp send_receipt(false, email, _func) do
    "Confirmation for #{email} failed"
  end
  defp send_receipt(user, email, func) do
    change(user, %{confirmed: true}) |> Config.repo.update!
    func.(email)
  end
end
