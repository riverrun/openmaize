defmodule Openmaize.Database do
  @moduledoc """
  ADD INSTRUCTIONS FOR MIX GENERATOR

  If you are going to create a custom module, note that the following
  functions are called by other modules in Openmaize:

    * `find_user` - used in Openmaize.Login and Openmaize.ConfirmEmail
    * `find_user_byid` - used in Openmaize.OnetimePass
    * `user_confirmed` - used in Openmaize.ConfirmEmail
    * `password_reset` - used in Openmaize.ResetPassword
    * `check_time` - used in Openmaize.ConfirmEmail and Openmaize.ResetPassword

  """

  @callback find_user(String.t, atom) :: struct
  @callback find_user_byid(String.t) :: struct
  @callback user_confirmed(struct) :: {:ok, struct} | {:error, struct}
  @callback password_reset(struct, String.t) :: {:ok, struct} | {:error, struct}
  @callback check_time(Integer | nil, Integer) :: boolean

end
