defmodule Openmaize.Config do
  @moduledoc """
  This module provides an abstraction layer for configuration.
  The following are valid configuration items.

  | name               | type    | default  |
  | :----------------- | :------ | -------: |
  | user_model         | module  | N/A      |
  | repo               | module  | N/A      |
  | crypto_mod         | atom    | :bcrypt  |
  | login_dir          | string  | "/admin" |
  | redirect_pages     | map     | %{"admin" => "/admin", nil => "/"} |
  | protected          | list    | %{"/admin" => ["admin"]} |
  | storage_method     | atom    | :cookie  |
  | unique             | atom    | :name    |
  | secret_key         | string  | "you will never guess" |
  | token_info         | list    | []       |
  | token_validity     | integer | 24 * 60  |

  The values for user_model and repo should be module names.
  If, for example, your app is called Coolapp and your user
  model is called User, then `user_model` should be
  Coolapp.User and `repo` should be Coolapp.Repo.

  ## Examples

  The simplest way to change the default values would be to add
  the following to the `config.exs` file in your project.

      config :openmaize,
        user_model: Coolapp.User,
        repo: Coolapp.Repo,
        crypto_mod: :bcrypt,
        login_dir: "admin",
        redirect_pages: %{"admin" => "/admin", "user" => "/users", nil => "/"},
        protected: %{"/admin" => ["admin"], "/users" => ["admin", "user"], "/users/:id" => ["user"]}
        storage_method: :cookie,
        unique: :email,
        secret_key: "so hard to guess",
        token_info: [:email, :shoesize],
        token_validity: 7 * 24 * 60

  """

  @doc """
  The user model name.
  """
  def user_model do
    Application.get_env(:openmaize, :user_model)
  end

  @doc """
  The repo name.
  """
  def repo do
    Application.get_env(:openmaize, :repo)
  end

  @doc """
  The password hashing and checking algorithm. You can choose between
  bcrypt and pbkdf2_sha512. Bcrypt is the default.

  For more information about these two algorithms, see the documentation
  for Comeonin.
  """
  def get_crypto_mod do
    case crypto_mod do
      :pbkdf2 -> Comeonin.Pbkdf2
      _ -> Comeonin.Bcrypt
    end
  end
  defp crypto_mod do
    Application.get_env(:openmaize, :crypto_mod, :bcrypt)
  end

  @doc """
  The login directory. For example, the default value of "/admin" means
  that the login page is "/admin/login".
  """
  def login_dir do
    Application.get_env(:openmaize, :login_dir, "/admin")
  end

  @doc """
  The pages users should be redirected to after logging in. This is a
  map where the key is the role of the user and the value is the page
  to be redirected to.

  If there is no role, the user will be redirected to the home page.
  """
  def redirect_pages do
    default = %{"admin" => "/admin", nil => "/"}
    Application.get_env(:openmaize, :redirect_pages, default)
  end

  @doc """
  Paths that should be protected. This is a map associating each path
  with a role.

  The path is the start of the path. For example, "/users" refers to
  all paths that start with "/users".
  """
  def protected do
    default = %{"/admin" => ["admin"]}
    Application.get_env(:openmaize, :protected, default)
  end

  @doc """
  The storage method for the token. The default is to store it in
  a cookie which is then sent to the user.

  The token can also be sent in the body of the response, which is the
  default if you call Openmaize with the `redirects: false` option. For
  subsequent requests, the token can then be sent back in the request
  headers.
  """
  def storage_method do
    Application.get_env(:openmaize, :storage_method, :cookie)
  end

  @doc """
  The unique key by which the user can be identified when making the
  database calls, for example when logging in. This should be an atom.
  """
  def unique do
    Application.get_env(:openmaize, :unique, :name)
  end

  @doc """
  The secret key for use with Joken (which encodes and decodes the
  tokens).

  In production, the default key should be changed.
  """
  def secret_key do
    Application.get_env(:openmaize, :secret_key, "you will never guess")
  end

  @doc """
  Additional information that can be added to the token. By default,
  the token will have an id, name and role.

  This value takes a list of atoms.
  """
  def token_info do
    Application.get_env(:openmaize, :token_info, []) ++ [:id, unique, :role]
  end

  @doc """
  The number of minutes that you want the token to be valid for.
  """
  def token_validity do
    Application.get_env(:openmaize, :token_validity_in_minutes, 24 * 60) * 60
  end

end
