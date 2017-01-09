defmodule <%= base %>.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :email, :string<%= if not unique_id in [":username", ":email"] do %>
      add <%= unique_id %>, :string<% end %>
      add :password_hash, :string<%= if confirm do %>
      add :confirmed_at, :utc_datetime
      add :confirmation_token, :string
      add :confirmation_sent_at, :utc_datetime
      add :reset_token, :string
      add :reset_sent_at, :utc_datetime<% end %>

      timestamps()
    end

    create unique_index :users, [<%= unique_id %>]
  end
end
