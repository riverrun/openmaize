defmodule Openmaize.Config do
  @moduledoc """
  This module provides an abstraction layer for configuration.

  The following are valid configuration items.

  | name               | type    | default  |
  | :----------------- | :------ | -------: |
  | user_model         | module  | N/A      |
  | repo               | module  | N/A      |
  | db_module          | module  | Openmaize.DB   |
  | hash_name          | atom    | :password_hash |
  | crypto_mod         | atom    | :bcrypt  |
  | token_alg          | atom    | :sha512  |
  | token_validity     | int     | 120 (minutes)  |
  | keyrotate_days     | int     | 28       |
  | redirect_pages     | map     | %{"admin" => "/admin", "login" => "/login", "logout" => "/"} |
  | password_strength  | keyword list | []  |

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
        db_module: Coolapp.DB,
        hash_name: :encrypted_password,
        crypto_mod: :pbkdf2,
        token_alg: :sha256,
        token_validity: 60,
        keyrotate_days: 7,
        redirect_pages: %{"admin" => "/admin", "login" => "/admin/login", "logout" => "/admin/login"},
        password_strength: [min_length: 12]

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
  The name of the database module.

  You only need to set this value if you plan on overriding the
  the functions in the Openmaize.DB module. If you are using Ecto,
  you will probably not need to set this value.
  """
  def db_module do
    Application.get_env(:openmaize, :db_module, Openmaize.DB)
  end

  @doc """
  The name in the database for the password hash.
  """
  def hash_name do
    Application.get_env(:openmaize, :hash_name, :password_hash)
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
  The algorithm used to sign the token.

  The default value is :sha512, and :sha256 is also supported.
  """
  def get_token_alg do
    case token_alg do
      :sha256 -> {"HS256", :sha256}
      _ -> {"HS512", :sha512}
    end
  end
  defp token_alg do
    Application.get_env(:openmaize, :token_alg, :sha512)
  end

  @doc """
  The length of time after which a JSON Web Token expires.

  The default length of time is 120 minutes (2 hours).
  """
  def token_validity do
    Application.get_env(:openmaize, :token_validity, 120)
  end

  @doc """
  The number of days after which the JWT signing keys will be rotated.
  """
  def keyrotate_days do
    Application.get_env(:openmaize, :keyrotate_days, 28)
  end

  @doc """
  The pages users should be redirected to after logging in or if there
  is an error.

  This is a map where the key is the role of the user and the value is
  the page to be redirected to.

  ## Redirects for login and logout

  The "login" key refers to the login page that unauthorized users should
  be redirected to. The default value is "/login".

  The "logout" key refers to the page users should be redirected to after
  logging out. The default value is "/".
  """
  def redirect_pages do
    Map.merge(%{"login" => "/login", "logout" => "/"},
    Application.get_env(:openmaize, :redirect_pages, %{"admin" => "/admin"}))
  end

  @doc """
  Options for the password strength check.

  The basic check will just check the minimum length, which is 8 characters
  by default. For a more advanced check, you need to have the optional
  dependency NotQwerty123 installed.

  ## Advanced password strength check

  If you have NotQwerty123 installed, there are three options:

  * min_length - the minimum length of the password
  * extra_chars - check for punctuation characters (including spaces) and digits
  * common - check to see if the password is too common (too easy to guess)

  See the documentation for Openmaize.Password for more information about
  these options.

  ## Examples

  In the following example, the password strength check will set the minimum
  length to 16 characters and will skip the `extra_chars` check:

      password_strength: [min_length: 16, extra_chars: false]

  """
  def password_strength do
    Application.get_env(:openmaize, :password_strength, [])
  end
end
