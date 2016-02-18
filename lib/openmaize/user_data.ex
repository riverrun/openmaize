defmodule Openmaize.UserData do
  @moduledoc """
  Module used to create a struct from the JSON Web Token data.
  """

  defstruct id: 1, role: "", sub: "", user: %{}

end
