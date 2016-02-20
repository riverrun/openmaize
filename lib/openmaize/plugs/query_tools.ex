defmodule Openmaize.QueryTools do
  @moduledoc """
  Query the database.

  The `find_user` function is called by Openmaize.Login, but
  this can be replaced with a custom function.
  """

  import Ecto.Query
  alias Openmaize.Config

  @doc """
  Find the user in the database.
  """
  def find_user(user_id, uniq) do
    from(u in Config.user_model,
         where: field(u, ^uniq) == ^user_id,
         select: u)
    |> Config.repo.one
  end

end
