defmodule Openmaize.EctoDB do

  import Ecto.Changeset
  alias Openmaize.{TestRepo, TestUser, TestOldOtpToken}
  alias Openmaize.{Config, Password}

  @behaviour Openmaize.Database

  def find_user(user_id, uniq) do
    TestRepo.get_by(TestUser, [{uniq, user_id}])
  end

  def find_user_by_id(id) do
    TestRepo.get(TestUser, id)
  end

  def add_password_hash(user, params) do
    (params[:password] || params["password"])
    |> Password.valid_password?(Config.password_strength)
    |> add_hash_changeset(user)
  end

  def add_confirm_token(user, key) do
    change(user, %{confirmation_token: key,
      confirmation_sent_at: Ecto.DateTime.utc})
  end

  def add_reset_token(user, key) do
    change(user,
     %{reset_token: key, reset_sent_at: Ecto.DateTime.utc})
  end

  def user_confirmed(user) do
    change(user, %{confirmed_at: Ecto.DateTime.utc})
    |> TestRepo.update
  end

  def password_reset(user, password) do
    Password.valid_password?(password, Config.password_strength)
    |> reset_update_repo(user)
  end

  def check_time(nil, _), do: false
  def check_time(sent_at, valid_secs) do
    (sent_at |> Ecto.DateTime.to_erl
     |> :calendar.datetime_to_gregorian_seconds) + valid_secs >
    (:calendar.universal_time |> :calendar.datetime_to_gregorian_seconds)
  end

  defp add_hash_changeset({:ok, password}, user) do
    change(user, %{Config.hash_name =>
      Config.crypto_mod.hashpwsalt(password)})
  end
  defp add_hash_changeset({:error, message}, user) do
    change(user, %{password: ""})
    |> add_error(:password, message)
  end

  defp reset_update_repo({:ok, password}, user) do
    TestRepo.transaction(fn ->
      user = change(user, %{Config.hash_name =>
        Config.crypto_mod.hashpwsalt(password)})
      |> TestRepo.update!

      change(user, %{reset_token: nil, reset_sent_at: nil})
      |> TestRepo.update!
    end)
  end
  defp reset_update_repo({:error, message}, _user) do
    {:error, message}
  end

  
  def old_otp_token?(user_id, totp) do
    # Try to load the record for the given user_id and token,
    #   if it fails (nil), it means that the token is used for the first time,
    #   else it means that the token was already used before.
    result = TestRepo.get_by(TestOldOtpToken, user_id: user_id, token: totp)
    case result do
      nil -> :is_new
      _   -> :is_old
    end
  end

  def add_token_to_old_tokens(user_id, token) do
    # Store the token in the database
    TestRepo.insert!(%TestOldOtpToken{user_id: String.to_integer(user_id), token: token})
  end


end
