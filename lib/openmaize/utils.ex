defmodule Openmaize.Utils do
  @moduledoc false

  @doc """
  Get the default name for the db_module.
  """
  def default_db do
    base_name() |> Module.concat(OpenmaizeEcto)
  end

  @doc """
  Get the mix project name.
  """
  def base_name do
    Mix.Project.config |> Keyword.fetch!(:app) |> to_string |> Macro.camelize
  end
end
