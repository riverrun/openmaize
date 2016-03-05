defmodule Openmaize.AccessControl do
  @moduledoc """
  These functions have been deprecated.

  Please use `Openmaize.Authorize` or `Openmaize.AuthorizeId` instead.
  """

  @doc false
  def authorize(_conn, _opts) do
    IO.write :stderr, "warning: calling 'plug :authorize' is deprecated, " <>
      "please use 'Openmaize.Authorize' instead.\n"
  end

  @doc false
  def authorize_id(_conn, _opts) do
    IO.write :stderr, "warning: calling 'plug :authorize_id' is deprecated, " <>
      "please use 'Openmaize.AuthorizeId' instead.\n"
  end
end
