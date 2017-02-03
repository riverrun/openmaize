defmodule Openmaize.Login do
  @moduledoc """
  Module to handle login.

  There are three options:

    * repo - the name of the repo
      * the default is MyApp.Repo - using the name of the project
    * user_model - the name of the user model
      * the default is MyApp.User - using the name of the project

  ## Examples with Phoenix

  The easiest way to use this plug is to run the
  `mix openmaize.gen.phoenixauth` command, which will create
  all the files you need.

  If you do not want to run the above command, you need to create the
  following files:

    * controllers/session_controller.ex
    * views/session_view.ex
    * templates/session/new.html.eex

  In the `new.html.eex` file, make sure that the form uses `session` to
  identify the user.

  You also need to add the following command to the `web/router.ex` file:

      resources "/sessions", SessionController, only: [:new, :create, :delete]

  Add the following command to the `session_controller.ex` file:

      plug Openmaize.Login when action in [:create]

  If you want to use `email` to identify the user:

      plug Openmaize.Login, [unique_id: :email] when action in [:create]

  If you want to use `email` or `username` to identify the user (allowing the
  end user a choice):

      plug Openmaize.Login, [unique_id: &Openmaize.Login.Name.email_username/1] when action in [:create]

  """

  use Openmaize.Login.Base

end
