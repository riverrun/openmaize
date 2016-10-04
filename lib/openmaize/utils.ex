defmodule Openmaize.Utils do
  @moduledoc false

  @doc """
  Get the default name for the db_module.
  """
  def default_db do
    base_module() |> Module.concat(OpenmaizeEcto)
  end

  @doc """
  Get the mix project module name.
  """
  def base_module do
    base_name() |> Macro.camelize
  end

  @doc """
  Get the mix project name - as a string.
  """
  def base_name do
    Mix.Project.config |> Keyword.fetch!(:app) |> to_string
  end
end
