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

defmodule Openmaize.Case do
  use ExUnit.CaseTemplate
  setup_all do
    Ecto.Adapters.SQL.begin_test_transaction(TestRepo, [])
    on_exit fn -> Ecto.Adapters.SQL.rollback_test_transaction(TestRepo, []) end
    :ok
  end
  setup do
    Ecto.Adapters.SQL.restart_test_transaction(TestRepo, [])
    :ok
  end
end

defmodule UsersMigration do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :password_hash, :string
      add :role, :string
      add :confirmed_at, :datetime
      add :confirmation_token, :string
      add :confirmation_sent_at, :datetime
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
    field :role, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :confirmed_at, Ecto.DateTime
    field :confirmation_token, :string
    field :confirmation_sent_at, Ecto.DateTime
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(email role), ~w())
    |> validate_length(:email, min: 1, max: 100)
    |> unique_constraint(:email)
  end

  def auth_changeset(model, params, key) do
    model
    |> changeset(params)
    |> Openmaize.Signup.add_password_hash(params)
    |> Openmaize.Signup.add_confirm_token(key)
  end
end
