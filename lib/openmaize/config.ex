defmodule Openmaize.Config do
  @moduledoc """
  This module provides an abstraction layer for configuration.

  The following are valid configuration items.


  | name               | type         | default          |
  | :----------------- | :----------- | ---------------: |
  | db_module          | module       | N/A              |
  | crypto_mod         | module       | Comeonin.Bcrypt  |
  | hash_name          | atom         | :password_hash   |
  | password_strength  | keyword list | []               |

  ## Examples

  The simplest way to change the default values would be to add
  an `openmaize` entry to the `config.exs` file in your project,
  like the following example.

      config :openmaize,
        db_module: Coolapp.DB,
        crypto_mod: Comeonin.Bcrypt,
        hash_name: :encrypted_password,
        password_strength: [min_length: 12]

  """

  @doc """
  The name of the database module.
  """
  def db_module do
    Application.get_env(:openmaize, :db_module)
  end

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
