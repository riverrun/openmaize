defmodule Openmaize.Database do
  @moduledoc """
  A behaviour which defines the functions that are called by other
  Openmaize modules.

  If you are using Ecto, you can generate a module that defines these
  functions by running the following command:

      mix openmaize.gen.ectodb

  """

  @doc """
  Query the database to find the current user based on a unique
  identifier - username, email, or anything else.

  The first argument is a string representing the user's username
  or email (or something else). The second argument is an atom
  which represents what the unique identifier, :username or
  :email, etc., is.

  This function returns a user struct.
  """
  @callback find_user(String.t, atom) :: struct

  @doc """
  Query the database based on the user id.

  The only argument is the user id.

  This function returns a user struct.
  """
  @callback find_user_by_id(String.t | Integer) :: struct

  @doc """
  Update the database with the time when the email address was confirmed.

  The only argument is the user struct.

  This function returns a {:ok, user struct} or {:error, changeset (struct)}.
  """
  @callback user_confirmed(struct) :: {:ok, struct} | {:error, struct}

  @doc """
  Add the password hash for the new password to the database.

  If the update is successful, the reset_token and reset_sent_at
  values will be set to nil.

  The first argument is the user struct, and the second argument is
  the password.

  This function returns a {:ok, user struct} or {:error, error message}.
  """
  @callback password_reset(struct, String.t) :: {:ok, struct} | {:error, String.t}

  @doc """
  Function used to check if a token has expired.

  The first argument is the time when the token was created, and the second
  argument is the number of seconds the token is valid for.

  This function returns true or false.
  """
  @callback check_time(Integer | nil, Integer) :: boolean

end
