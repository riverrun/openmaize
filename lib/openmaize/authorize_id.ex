defmodule Openmaize.AuthorizeId do
  @moduledoc """
  Verify that the user, based on the user id, is authorized to access the
  requested page / resource.

  This check only performs a check to see if the user id is correct. You will
  need to use the `Openmaize.Authorize` plug to verify the user's role.

  ## Examples with Phoenix

  In each of the following examples, the `plug` command needs to be added
  to the relevant controller file.

  To not allow other users to view or edit the user's page:

      plug Openmaize.AuthorizeId, when action in [:show, :edit]

  """

  use Openmaize.Authorize.Base

  @doc false
  def call(%Plug.Conn{params: %{"id" => id},
                      assigns: %{current_user: current_user}} = conn,
           {_roles}) do
    id_check(conn, id, current_user)
  end

end
