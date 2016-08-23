defmodule Openmaize.DummyUser do

  schema "users" do
    field :username, :string
    field :password, :string
    field :password_hash, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username, :password_hash])
    |> validate_required([:username, :password_hash])
  end
end
