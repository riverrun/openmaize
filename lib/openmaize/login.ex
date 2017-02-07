defmodule Openmaize.Login do
  @moduledoc """
  Module to handle login.

  There are two options:

    * repo - the name of the repo
      * the default is MyApp.Repo - using the name of the project
    * user_model - the name of the user model
      * the default is MyApp.User - using the name of the project

  See the documentation for Openmaize.Login.Base for information about
  creating a custom Plug for logins.
  """

  use Openmaize.Login.Base

end
