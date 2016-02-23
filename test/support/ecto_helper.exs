alias Openmaize.TestRepo

Application.put_env(:openmaize, TestRepo,
  adapter: Ecto.Adapters.Postgres,
  username: "dev",
  password: System.get_env("POSTGRES_PASS"),
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
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(email role), ~w(username phone confirmed_at))
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
