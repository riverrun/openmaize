alias Openmaize.TestRepo

Application.put_env(:openmaize, :pg_test_url,
  "ecto://" <> (System.get_env("PG_URL") || "postgres:postgres@localhost")
)

Application.put_env(:openmaize, TestRepo,
  adapter: Ecto.Adapters.Postgres,
  url: Application.get_env(:openmaize, :pg_test_url) <> "/openmaize_test",
  url: "ecto://localhost/openmaize_test",
  pool: Ecto.Adapters.SQL.Sandbox)

defmodule Openmaize.TestRepo do
  use Ecto.Repo, otp_app: :openmaize
end

defmodule UsersMigration do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :username, :string
      add :phone, :string
      add :password_hash, :string
      add :role, :string
      add :confirmed_at, :datetime
      add :confirmation_token, :string
      add :confirmation_sent_at, :datetime
      add :reset_token, :string
      add :reset_sent_at, :datetime
      add :otp_required, :boolean
      add :otp_secret, :string
    end

    create unique_index :users, [:email]
  end
end

# Load up the repository, start it, and run migrations
Ecto.Storage.down(TestRepo)
:ok = Ecto.Storage.up(TestRepo)
{:ok, pid} = TestRepo.start_link
:ok = Ecto.Migrator.up(TestRepo, 0, UsersMigration, log: false)

defmodule Openmaize.User do
  use Ecto.Schema

  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :username, :string
    field :phone, :string
    field :role, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :confirmed_at, Ecto.DateTime
    field :confirmation_token, :string
    field :confirmation_sent_at, Ecto.DateTime
    field :reset_token, :string
    field :reset_sent_at, Ecto.DateTime
    field :otp_required, :boolean
    field :otp_secret, :string
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(email role), ~w(username phone confirmed_at otp_required otp_secret))
    |> validate_length(:email, min: 1, max: 100)
    |> unique_constraint(:email)
  end

  def auth_changeset(model, params) do
    model
    |> changeset(params)
    |> Openmaize.DB.add_password_hash(params)
  end

  def confirm_changeset(model, params, key) do
    model
    |> auth_changeset(params)
    |> Openmaize.DB.add_confirm_token(key)
  end
end
