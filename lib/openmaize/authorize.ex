defmodule Openmaize.Authorize do
  @moduledoc """
  Verify that the user is authorized to access the requested page / resource.

  This check is based on user role.

  This function has two options:

  * roles - a list of permitted roles
  * redirects - if true, which is the default, redirect if there is an error

  ## Examples with Phoenix

  In each of the following examples, the `plug` command needs to be added
  to the relevant controller file.

  To only allow users with the role "admin" to access the pages in that module:

      plug Openmaize.Authorize, roles: ["admin"]

  To only allow users with the role "admin" to access the create and update pages
  (this means that the other pages are unprotected):

      plug Openmaize.Authorize, [roles: ["admin"]] when action in [:create, :update]

  To allow users with the role "admin" or "user" to access pages, and set
  redirects to false (this example protects every page except the index page):

      plug Openmaize.Authorize, [roles: ["admin", "user"], redirects: false] when not action in [:index]

  To allow users with the role "admin" or "user" to access the index, but
  only allow those users with the role "admin" to access the other pages.

      plug Openmaize.Authorize, [roles: ["admin", "user"]] when action in [:index]
      plug Openmaize.Authorize, [roles: ["admin"]] when not action in [:index]

  """

  use Openmaize.Authorize.Base

end
