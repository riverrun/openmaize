defmodule <%= base %>.User do
  use <%= base %>.Web, :model

  alias <%= base %>.OpenmaizeEcto

  schema "users" do
    field :username, :string
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string<%= if confirm do %>
    field :confirmed_at, Ecto.DateTime
    field :confirmation_token, :string
    field :confirmation_sent_at, Ecto.DateTime
    field :reset_token, :string
    field :reset_sent_at, Ecto.DateTime<% end %>

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username, :email])
    |> validate_required([:username, :email])
    |> unique_constraint(:username)
  end

  def auth_changeset(struct, params, key) do
    struct
    |> changeset(params)
    |> OpenmaizeEcto.add_password_hash(params)<%= if confirm do %>
    |> OpenmaizeEcto.add_confirm_token(key)<% end %>
  end<%= if confirm do %>

  def reset_changeset(struct, params, key) do
    struct
    |> cast(params, [:email], [])
    |> OpenmaizeEcto.add_reset_token(key)
  end<% end %>
end
