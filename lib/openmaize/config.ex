defmodule Openmaize.Config do
  @moduledoc """
  This module provides an abstraction layer for configuration.

  The following are valid configuration items.


  | name               | type          | default          |
  | :----------------- | :-----------  | ---------------: |
  | crypto_mod         | module        | Comeonin.Bcrypt  |
  | hash_name          | atom          | :password_hash   |
  | drop_user_keys     | list of atoms | []               |
  | password_min_len   | integer       | 8                |
  | remember_salt      | string        | N/A              |

  ## Examples

  The simplest way to change the default values would be to add
  an `openmaize` entry to the `config.exs` file in your project,
  like the following example.

      config :openmaize,
        crypto_mod: Comeonin.Bcrypt,
        hash_name: :encrypted_password,
        drop_user_keys: [:shoe_size],
        password_min_len: 12

  """

  @doc """
  The password hashing and checking algorithm. Bcrypt is the default.

  You can supply any module, but the module must implement the following
  functions:

    * hashpwsalt/1 - hashes the password
    * checkpw/2 - given a password and a salt, returns if match
    * dummy_checkpw/0 - performs a hash and returns false

  See Comeonin.Bcrypt for examples.
  """
  def crypto_mod do
    Application.get_env(:openmaize, :crypto_mod, Comeonin.Bcrypt)
  end

  @doc """
  The name in the database for the password hash.
  """
  def hash_name do
    Application.get_env(:openmaize, :hash_name, :password_hash)
  end

  @doc """
  The log level.
  """
  def log_level do
    Application.get_env(:openmaize, :log_level, :info)
  end

  @doc """
  The keys that are removed from the user struct before it is passed
  on to another function.

  This should be a list of atoms.

  By default, :password_hash (or the value for hash_name), :password,
  :otp_secret, :confirmation_token and :reset_token are removed, and
  this option allows you to add to this list.
  """
  def drop_user_keys do
    Application.get_env(:openmaize, :drop_user_keys, []) ++
    [hash_name(), :password, :otp_secret, :confirmation_token, :reset_token]
  end

  @doc """
  Minimum length for the password strength check.

  The default minimum length is 8.

  The Openmaize.Password module provides a basic check and an advanced
  check, both of which use the `password_min_len` value. For more
  information about the advanced check, see the documentation for
  the Openmaize.Password module.
  """
  def password_min_len do
    Application.get_env(:openmaize, :password_min_len, 8)
  end

  @doc """
  Salt to be used when signing and verifying the `remember me` cookie.
  """
  def remember_salt do
    Application.get_env(:openmaize, :remember_salt)
  end
end
