defmodule Openmaize.Login.Email do
  @moduledoc """
  Module to handle login with email address.

  There are two options:

    * repo - the name of the repo
      * the default is MyApp.Repo - using the name of the project
    * user_model - the name of the user model
      * the default is MyApp.User - using the name of the project

  See the documentation for Openmaize.Login.Base for information about
  creating a custom Plug for logins.
  """

  use Openmaize.Login.Base

  def unpack_params(%{"email" => email, "password" => password}) do
    {:email, email, password}
  end
  def unpack_params(_), do: nil
end
