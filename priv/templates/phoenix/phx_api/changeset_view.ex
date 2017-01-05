defmodule <%= base %>.ChangesetView do
  use <%= base %>.Web, :view

  @doc """
  Traverses and translates changeset errors.

  See `Ecto.Changeset.traverse_errors/2` and
  `<%= base %>.ErrorHelpers.translate_error/1` for more details.
  """
  def translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
  end

  def render("error.json", %{changeset: changeset}) do
    %{errors: translate_errors(changeset)}
  end
end
