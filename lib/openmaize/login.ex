vars = [{Openmaize.Login, "username", :username},
        {Openmaize.EmailLogin, "email", :email}]

for {mod, user_params, user_id} <- vars do
  defmodule mod do
    @moduledoc """
    Module to handle login using #{user_params} as user id.

    There are two options:

      * repo - the name of the repo
        * the default is MyApp.Repo - using the name of the project
      * user_model - the name of the user model
        * the default is MyApp.User - using the name of the project

    See the documentation for Openmaize.Login.Base for information about
    creating a custom Plug for logins.
    """

    use Openmaize.Login.Base

    unless user_params == "username" do
      def unpack_params(%{unquote(user_params) => user, "password" => password}) do
        {unquote(user_id), user, password}
      end
      def unpack_params(_), do: nil
    end
  end
end
