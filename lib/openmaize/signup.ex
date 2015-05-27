defmodule Openmaize.Signup do
  @moduledoc """
  """

  alias Openmaize.Config

  @doc """
  This function takes a map with a password in it, removes the password
  and adds an entry for the password hash.
  """
  def create_user(user_params, valid \\ true) do
    Comeonin.create_user(user_params, valid)
  end

end
